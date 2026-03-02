// ddotfiles/packages/yo-rs/src/yo-tests.rs ⮞ https://github.com/QuackHack-McBlindy/dotfiles
use std::{ // 🦆 says ⮞ yo-tests (Automated Sentence Testing)
    env,
    fs::{OpenOptions, File},
    io::{self, Write},
    sync::Once,
    time::Instant,
};
use ducktrace_logger::*;


use std::collections::HashMap;
use std::fs;
use std::process::{Command, exit};
use regex::Regex;
use serde::{Deserialize, Serialize};
use colored::*;

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ScriptConfig {
    description: String,
    category: String,
    voice: Option<VoiceConfig>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct VoiceConfig {
    enabled: bool,
    priority: i32,
    sentences: Vec<String>,
    lists: HashMap<String, ListConfig>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ListConfig {
    wildcard: bool,
    values: Vec<ListValue>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ListValue {
    r#in: String,
    out: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct IntentData {
    substitutions: Vec<Substitution>,
    sentences: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Substitution {
    pattern: String,
    value: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct FuzzyIndexEntry {
    script: String,
    sentence: String,
    signature: String,
}

struct TestRunner {
    intent_data: HashMap<String, IntentData>,
    fuzzy_index: Vec<FuzzyIndexEntry>,
    debug: bool,
    stats_mode: bool,
    single_input: Option<String>,
}

#[derive(Debug)]
struct TestResult {
    passed_positive: usize,
    total_positive: usize,
    passed_negative: usize,
    total_negative: usize,
    passed_boundary: usize,
    total_boundary: usize,
    failures: Vec<String>,
    processing_time: std::time::Duration,
}

impl TestRunner {
    fn new() -> Self {
        Self {
            intent_data: HashMap::new(),
            fuzzy_index: Vec::new(),
            debug: env::var("DEBUG").is_ok() || env::var("DT_DEBUG").is_ok(),
            stats_mode: false,
            single_input: None,
        }
    }

    // 🦆 says ⮞ load data from env var
    fn load_data(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        if let Ok(intent_data_path) = env::var("YO_INTENT_DATA") {
            let data = fs::read_to_string(intent_data_path)?;
            self.intent_data = serde_json::from_str(&data)?;
            self.quack_debug(&format!("🦆 Loaded intent data for {} scripts", self.intent_data.len()));
        }

        if let Ok(fuzzy_index_path) = env::var("YO_FUZZY_INDEX") {
            let data = fs::read_to_string(fuzzy_index_path)?;
            self.fuzzy_index = serde_json::from_str(&data)?;
            self.quack_debug(&format!("🦆 Loaded {} fuzzy index entries", self.fuzzy_index.len()));
        }
        Ok(())
    }

    fn quack_debug(&self, msg: &str) {
        if self.debug {
            eprintln!("[🦆📜] ⁉️DEBUG⁉️ ⮞ {}", msg);
        }
    }

    fn quack_info(&self, msg: &str) {
        eprintln!("[🦆📜] ✅INFO✅ ⮞ {}", msg);
    }

    // 🦆 says ⮞ word expansion same algorithm as da Nix version
    fn expand_optional_words(&self, sentence: &str) -> Vec<String> {
        let tokens: Vec<&str> = sentence.split_whitespace().collect();
        let mut variants = Vec::new();
        
        fn generate_combinations(tokens: &[&str], current: Vec<String>, index: usize, result: &mut Vec<String>) {
            if index >= tokens.len() {
                let sentence = current.join(" ").trim().to_string();
                if !sentence.is_empty() {
                    result.push(sentence);
                }
                return;
            }

            let token = tokens[index];
            let mut alternatives = Vec::new();

            // 🦆 says ⮞ handle (required|alternatives)
            if token.starts_with('(') && token.ends_with(')') {
                let clean = &token[1..token.len()-1];
                alternatives.extend(clean.split('|').map(|s| s.to_string()));
            } 
            // 🦆 says ⮞ handle [optional|words]
            else if token.starts_with('[') && token.ends_with(']') {
                let clean = &token[1..token.len()-1];
                alternatives.extend(clean.split('|').map(|s| s.to_string()));
                alternatives.push("".to_string());
            } 
            // 🦆 says ⮞ regular token
            else {
                alternatives.push(token.to_string());
            }

            for alt in alternatives {
                let mut new_current = current.clone();
                if !alt.is_empty() {
                    new_current.push(alt);
                }
                generate_combinations(tokens, new_current, index + 1, result);
            }
        }

        generate_combinations(&tokens, Vec::new(), 0, &mut variants);
        
        // 🦆 says ⮞ clean and filter
        variants.iter()
            .map(|v| v.replace("  ", " ").trim().to_string())
            .filter(|v| !v.is_empty())
            .collect()
    }

    // 🦆 says ⮞ resolve sentence / mimic resolve_sentences
    fn resolve_sentence(&self, script_name: &str, sentence: &str) -> String {
        let mut resolved = sentence.to_string();
        
        // 🦆 says ⮞ extract param like {param}
        let param_pattern = Regex::new(r"\{([^}]+)\}").unwrap();
        let mut params: Vec<String> = Vec::new();
        
        for cap in param_pattern.captures_iter(sentence) {
            if let Some(param) = cap.get(1) {
                params.push(param.as_str().to_string());
            }
        }

        // 🦆 says ⮞ replace da param with da example values
        for param in params {
            let replacement = if param.to_lowercase().contains("hour") 
                || param.to_lowercase().contains("minute") 
                || param.to_lowercase().contains("second") {
                "1".to_string()
            } else if param.to_lowercase().contains("room") 
                || param.to_lowercase().contains("device") {
                "livingroom".to_string()
            } else {
                "test".to_string()
            };
            
            resolved = resolved.replace(&format!("{{{}}}", param), &replacement);
        }

        // 🦆 says ⮞ handle alternatives (word1|word2) pick da first yo
        let required_pattern = Regex::new(r"\(([^|)]+)(\|[^)]+)?\)").unwrap();
        resolved = required_pattern.replace_all(&resolved, "$1").to_string();
        
        // 🦆 says ⮞ handle optional words [word] steal da word
        let optional_pattern = Regex::new(r"\[([^]]+)\]").unwrap();
        resolved = optional_pattern.replace_all(&resolved, " $1 ").to_string();
        
        // 🦆 says ⮞ handle vertical bars in da alts
        resolved = resolved.replace(" | ", " ").to_string();
        
        // 🦆 says ⮞ clean da spaces
        resolved = resolved.replace("  ", " ").trim().to_string();

        resolved
    }

    // 🦆 says ⮞ exact matchin' testin'
    fn test_exact_match(&self, script_name: &str, input: &str) -> bool {
        if let Some(intent) = self.intent_data.get(script_name) {
            let normalized_input = input.to_lowercase();
            
            for sentence in &intent.sentences {
                let expanded_variants = self.expand_optional_words(sentence);
                
                for variant in expanded_variants {
                    // 🦆 says ⮞ build dynamic regex
                    let pattern = self.build_test_regex(&variant);
                    if let Ok(re) = Regex::new(&pattern) {
                        if re.is_match(&normalized_input) {
                            self.quack_debug(&format!("✅ EXACT MATCH: {} -> '{}'", script_name, input));
                            return true;
                        }
                    }
                }
            }
        }
        false
    }

    // 🦆 says ⮞ build test regex
    fn build_test_regex(&self, sentence: &str) -> String {
        let mut regex_parts = Vec::new();
        let mut current = sentence.to_string();

        // 🦆 says ⮞ exxtract da param & build regex
        while let Some(start) = current.find('{') {
            if let Some(end) = current.find('}') {
                let before_param = &current[..start];
                let param = &current[start+1..end];
                let after_param = &current[end+1..];

                if !before_param.is_empty() {
                    let escaped = regex::escape(before_param);
                    regex_parts.push(escaped);
                }

                // 🦆 says ⮞ wildcard vs specific parameters
                let regex_group = if param == "search" || param == "param" {
                    "(.*)".to_string()
                } else {
                    r"(\b[^ ]+\b)".to_string()
                };
                
                regex_parts.push(regex_group);
                current = after_param.to_string();
            } else {
                break;
            }
        }

        if !current.is_empty() {
            regex_parts.push(regex::escape(&current));
        }

        format!("^{}$", regex_parts.join(""))
    }

    // 🦆 says ⮞ test single input
    fn test_single_input(&self, input: &str) {
        println!("{}", "[🦆📜] Testing single input:".bright_blue());
        println!("{} '{}'", "   └─".bright_blue(), input);
        let mut matched = false;
        // 🦆 says ⮞ exact matchin' first
        for script_name in self.intent_data.keys() {
            if self.test_exact_match(script_name, input) {
                println!("{} {} {}", "   └─".green(), "✅ MATCH:".green(), script_name);
                matched = true;
                break;
            }
        }

        if !matched {
            // 🦆 says ⮞ fuzzy matchin'
            if let Some(fuzzy_match) = self.find_best_fuzzy_match(input) {
                println!("{} {} {} (score: {}%)", "   └─".yellow(), "FUZZY:".yellow(), fuzzy_match.0, fuzzy_match.1);
            } else {
                println!("{} {}", "   └─".red(), "❌ NO MATCH".red());
            }
        }
    }

    // 🦆 says ⮞ fuzzy matchin'
    fn find_best_fuzzy_match(&self, text: &str) -> Option<(String, i32)> {
        let normalized_input = text.to_lowercase();
        let mut best_score = 0;
        let mut best_match = None;

        for entry in &self.fuzzy_index {
            let normalized_sentence = entry.sentence.to_lowercase();
            let distance = self.levenshtein_distance(&normalized_input, &normalized_sentence);
            let max_len = normalized_input.len().max(normalized_sentence.len()); 
            if max_len == 0 { continue; }
            let score = 100 - (distance * 100 / max_len) as i32;
    
            if score >= 15 && score > best_score {
                best_score = score;
                best_match = Some((entry.script.clone(), score));
            }
        }
        best_match
    }

    fn levenshtein_distance(&self, a: &str, b: &str) -> usize {
        let a_chars: Vec<char> = a.chars().collect();
        let b_chars: Vec<char> = b.chars().collect();
        let a_len = a_chars.len();
        let b_len = b_chars.len();

        if a_len == 0 { return b_len; }
        if b_len == 0 { return a_len; }

        let mut matrix = vec![vec![0; b_len + 1]; a_len + 1];

        for i in 0..=a_len { matrix[i][0] = i; }
        for j in 0..=b_len { matrix[0][j] = j; }

        for i in 1..=a_len {
            for j in 1..=b_len {
                let cost = if a_chars[i-1] == b_chars[j-1] { 0 } else { 1 };
                matrix[i][j] = (matrix[i-1][j] + 1)
                    .min(matrix[i][j-1] + 1)
                    .min(matrix[i-1][j-1] + cost);
            }
        }
        matrix[a_len][b_len]
    }

    // 🦆 says ⮞ testin' suite
    fn run_test_suite(&self) -> TestResult {
        let start_time = Instant::now();
        let mut result = TestResult {
            passed_positive: 0,
            total_positive: 0,
            passed_negative: 0,
            total_negative: 0,
            passed_boundary: 0,
            total_boundary: 0,
            failures: Vec::new(),
            processing_time: std::time::Duration::default(),
        };

        self.test_positive_cases(&mut result);
        self.test_negative_cases(&mut result);
        self.test_boundary_cases(&mut result);

        result.processing_time = start_time.elapsed();
        result
    }

    fn test_positive_cases(&self, result: &mut TestResult) {
        println!("{}", "[🦆📜] Testing Positive Cases".bright_blue());

        for (script_name, intent) in &self.intent_data {
            println!("{} {}", "   └─ Testing script:".bright_blue(), script_name);

            for sentence in &intent.sentences {
                let expanded_variants = self.expand_optional_words(sentence);
                
                for variant in expanded_variants {
                    let test_sentence = self.resolve_sentence(script_name, &variant);
                    result.total_positive += 1;

                    print!("{} {}", "     Testing:".bright_blue(), test_sentence);

                    if self.test_exact_match(script_name, &test_sentence) {
                        println!(" {}", "✅".green());
                        result.passed_positive += 1;
                    } else {
                        println!(" {}", "❌".red());
                        result.failures.push(format!("POSITIVE: {} | {}", script_name, test_sentence));
                    }
                }
            }
        }
    }

    fn test_negative_cases(&self, result: &mut TestResult) {
        println!("{}", "[🦆🚫] Testing Negative Cases".bright_blue());

        let negative_cases = vec![
            "make me a sandwich",
            "launch the nuclear torpedos!",
            "gör mig en macka", 
            "avfyra kärnvapnen!",
            "ducks sure are the best dont you agree",
        ];

        for case in negative_cases {
            result.total_negative += 1;
            print!("{} {}", "   Testing:".bright_blue(), case);

            let mut matched = false;
            for script_name in self.intent_data.keys() {
                if self.test_exact_match(script_name, case) {
                    println!(" {}", "❌ FALSE POSITIVE".red());
                    result.failures.push(format!("NEGATIVE: {} | {}", script_name, case));
                    matched = true;
                    break;
                }
            }

            if !matched {
                println!(" {}", "✅".green());
                result.passed_negative += 1;
            }
        }
    }

    fn test_boundary_cases(&self, result: &mut TestResult) {
        println!("{}", "[🦆🔲] Testing Boundary Cases".bright_blue());
        let boundary_cases = vec!["", "   ", ".", "!@#$%^&*()"];

        for case in boundary_cases {
            result.total_boundary += 1;
            print!("{} '{}'", "   Testing:".bright_blue(), case);

            let mut matched = false;
            for script_name in self.intent_data.keys() {
                if self.test_exact_match(script_name, case) {
                    println!(" {}", "❌".red());
                    result.failures.push(format!("BOUNDARY: {} | '{}'", script_name, case));
                    matched = true;
                    break;
                }
            }

            if !matched {
                println!(" {}", "✅".green());
                result.passed_boundary += 1;
            }
        }
    }

    // 🦆 says ⮞ display statz yo
    fn display_stats(&self) {
        println!("{}", "[🦆📊] Voice Command Statistics".bright_blue());
        println!();

        let mut scripts_with_voice = Vec::new();

        for (script_name, intent) in &self.intent_data {
            let patterns = intent.sentences.len();
            let phrases: usize = intent.sentences.iter()
                .map(|s| self.expand_optional_words(s).len())
                .sum();
            
            let ratio = if patterns > 0 {
                phrases as f64 / patterns as f64
            } else {
                0.0
            };

            scripts_with_voice.push((script_name.clone(), patterns, phrases, ratio));
        }

        scripts_with_voice.sort_by(|a, b| b.3.partial_cmp(&a.3).unwrap());

        for (name, patterns, phrases, ratio) in scripts_with_voice {
            let ratio_str = if patterns == 0 {
                "∞".to_string()
            } else {
                format!("{:.1}", ratio)
            };

            let status = if patterns == 0 {
                "EMPTY".red()
            } else if phrases == 0 || (patterns > 0 && ratio < 0.5) {
                "NEEDS PHRASES".yellow()
            } else if ratio > 50.0 {
                "HIGH RATIO".bright_yellow()
            } else {
                "OK".green()
            };
            println!("{}: patterns={}, phrases={}, ratio={} - {}", 
                name, patterns, phrases, ratio_str, status);
        }

        println!();
        println!("{}", "Key insights:".bright_blue());
        println!("  • High pattern count decreases matching speed but increases accuracy");
        println!("  • High ratio (>50) may indicate over-complex patterns");
        println!("  • Use priority=5 for scripts with many patterns to optimize performance");
    }

    // 🦆 says ⮞ Final report
    fn display_final_report(&self, result: &TestResult) {
        let total_tests = result.total_positive + result.total_negative + result.total_boundary;
        let passed_tests = result.passed_positive + result.passed_negative + result.passed_boundary;
        let percent = if total_tests > 0 {
            (passed_tests * 100) / total_tests
        } else {
            0
        };

        let (color, duck_report) = if percent >= 80 {
            (Color::Green, "⭐")
        } else if percent >= 60 {
            (Color::Yellow, "🟢") 
        } else {
            (Color::Red, "😭")
        };

        // 🦆 says ⮞ display fails
        if passed_tests != total_tests && !result.failures.is_empty() {
            println!();
            println!("{}", "# ────── FAILURES ──────#".red());
            for failure in &result.failures {
                println!("{} {}", "## ❌".red(), failure);
            }
            println!("{}", "# ────── FAILURES ──────#".red());
        }

        println!();
        println!("{}", "# ──────⋆⋅☆⋅⋆────── #".color(color));
        println!("{}", "Testing completed!".bold());
        println!("{} {}", "Positive:".bold(), 
            format!("{}/{}", result.passed_positive, result.total_positive).color(color));
        println!("{} {}", "Negative:".bold(),
            format!("{}/{}", result.passed_negative, result.total_negative).color(color));
        println!("{} {}", "Boundary:".bold(),
            format!("{}/{}", result.passed_boundary, result.total_boundary).color(color));
        println!("{} {}", "TOTAL:".bold(),
            format!("{}/{} ({}%)", passed_tests, total_tests, percent).color(color));
        println!("{}", "# ──────⋆⋅☆⋅⋆────── #".color(color));
        println!("{}", duck_report);   
        self.quack_info(&format!("Test completed with results: {}/{} {}%", 
            passed_tests, total_tests, percent));
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    dt_setup(None, None);
    dt_debug("Started yo-tests!");
    let args: Vec<String> = env::args().collect();
    let mut test_runner = TestRunner::new();
    let mut stats_mode = false;
    let mut single_input = None;
    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--stats" => stats_mode = true,
            "--input" if i + 1 < args.len() => {
                single_input = Some(args[i + 1].clone());
                i += 1;
            }
            _ => {}
        }
        i += 1;
    }

    test_runner.stats_mode = stats_mode;
    test_runner.single_input = single_input;

    // 🦆 says ⮞ load test data
    test_runner.load_data()?;

    if test_runner.stats_mode {
        test_runner.display_stats();
    } else if let Some(input) = &test_runner.single_input {
        test_runner.test_single_input(input);
    } else {
        let result = test_runner.run_test_suite();
        test_runner.display_final_report(&result);
        
        if result.passed_positive + result.passed_negative + result.passed_boundary 
            != result.total_positive + result.total_negative + result.total_boundary {
            exit(1);
        }
    } 
    Ok(())
}
