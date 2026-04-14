use regex::escape;
use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet};
use std::fs;
use std::path::PathBuf;
use std::path::Path;
#[derive(Debug, Deserialize)]
struct Config {
    split_words: Option<Vec<String>>,
    sorry_phrases: Option<Vec<String>>,
    scripts: Vec<ScriptConfig>,
}

#[derive(Debug, Deserialize)]
struct ScriptConfig {
    name: String,
    description: String,
    category: Option<String>,
    parameters: Option<Vec<Parameter>>,
    code: Option<String>,
    binary: Option<String>,
    aliases: Option<Vec<String>>,
    log_level: Option<String>,
    auto_start: Option<bool>,
    run_every: Option<String>,
    run_at: Option<Vec<String>>,
    voice: Option<VoiceConfig>,
    visible_in_readme: Option<bool>,
    help_footer: Option<String>,
}


#[derive(Debug, Deserialize, Serialize, Clone)]
struct Parameter {
    name: String,
    #[serde(rename = "type")]
    param_type: Option<String>,
    description: Option<String>,
    optional: Option<bool>,
    default: Option<serde_json::Value>,
    values: Option<Vec<String>>,
}

#[derive(Debug, Deserialize, Clone)]
struct VoiceConfig {
    enabled: Option<bool>,
    priority: Option<u32>,
    sentences: Vec<String>,
    lists: Option<HashMap<String, List>>,
    fuzzy: Option<FuzzyConfig>,
}


#[derive(Debug, Deserialize, Serialize, Clone)]
struct List {
    wildcard: Option<bool>,
    values: Option<Vec<ValueMapping>>,
    range: Option<Range>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
struct ValueMapping {
    #[serde(rename = "in")]
    r#in: String,
    out: String,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
struct Range {
    from: i32,
    to: i32,
    multiplier: Option<i32>,
}


#[derive(Debug, Deserialize, Clone)]
struct FuzzyConfig {
    enable: Option<bool>,
}


#[derive(Debug, Clone)]
struct Script {
    description: String,
    category: Option<String>,
    parameters: Vec<Parameter>,
    code: Option<String>,
    binary: Option<String>,
    aliases: Vec<String>,
    log_level: String,
    auto_start: bool,
    run_every: Option<String>,
    run_at: Vec<String>,
    voice: Option<VoiceConfig>,
    visible_in_readme: bool,
    help_footer: Option<String>,
}


pub fn cartesian_product_of_lists<T: Clone>(lists: &[Vec<T>]) -> Vec<Vec<T>> {
    let mut result = vec![vec![]];
    for list in lists {
        let mut new_result = Vec::new();
        for prefix in &result {
            for item in list {
                let mut extended = prefix.clone();
                extended.push(item.clone());
                new_result.push(extended);
            }
        }
        result = new_result;
    }
    result
}


pub fn expand_optional_words(sentence: &str) -> Vec<String> {
    let tokens: Vec<&str> = sentence.split_whitespace().collect();

    let token_alts: Vec<Vec<String>> = tokens
        .iter()
        .map(|token| {
            if token.starts_with('(') && token.ends_with(')') {
                let inner = &token[1..token.len() - 1];
                inner.split('|').map(|s| s.trim().to_string()).collect()
            } else if token.starts_with('[') && token.ends_with(']') {
                let inner = &token[1..token.len() - 1];
                let mut alts: Vec<String> = inner.split('|').map(|s| s.trim().to_string()).collect();
                alts.push(String::new());
                alts
            } else {
                vec![token.to_string()]
            }
        })
        .collect();

    let product = cartesian_product_of_lists(&token_alts);

    let mut variants: Vec<String> = product
        .into_iter()
        .map(|tokens| tokens.join(" "))
        .map(|s| s.split_whitespace().collect::<Vec<_>>().join(" "))
        .filter(|s| !s.is_empty())
        .filter(|s| s.chars().any(|c| c != '{'))
        .collect();

    variants.sort();
    variants.dedup();
    variants
}


pub fn expand_list_input_variants(value: &str) -> Vec<String> {
    let tokens: Vec<&str> = value.split_whitespace().collect();

    let token_alts: Vec<Vec<String>> = tokens
        .iter()
        .map(|token| {
            if token.starts_with('[') && token.ends_with(']') {
                let inner = &token[1..token.len() - 1];
                inner.split('|').map(|s| s.trim().to_string()).collect()
            } else {
                vec![token.to_string()]
            }
        })
        .collect();

    let product = cartesian_product_of_lists(&token_alts);
    let mut variants: Vec<String> = product
        .into_iter()
        .map(|tokens| tokens.join(" "))
        .map(|s| s.split_whitespace().collect::<Vec<_>>().join(" "))
        .filter(|s| !s.is_empty())
        .collect();

    variants.sort();
    variants.dedup();
    variants
}


pub fn expand_to_regex(sentence: &str, lists: Option<&HashMap<String, List>>) -> String {
    enum Token<'a> {
        Literal(&'a str),
        Parameter(&'a str),
    }

    let mut tokens = Vec::new();
    let mut remaining = sentence;
    let re = regex::Regex::new(r"([^{]*)(\{[^}]*\})?(.*)").unwrap();

    while !remaining.is_empty() {
        if let Some(caps) = re.captures(remaining) {
            let literal = caps.get(1).map(|m| m.as_str()).unwrap_or("");
            let param = caps.get(2).map(|m| m.as_str());
            let rest = caps.get(3).map(|m| m.as_str()).unwrap_or("");

            if !literal.is_empty() {
                tokens.push(Token::Literal(literal));
            }
            if let Some(p) = param {
                tokens.push(Token::Parameter(p));
            }
            remaining = rest;
        } else {
            tokens.push(Token::Literal(remaining));
            break;
        }
    }

    fn pattern_to_regex(s: &str) -> String {
        let mut result = String::new();
        let mut chars = s.chars().peekable();

        while let Some(c) = chars.next() {
            match c {
                '(' => {
                    let inner = collect_group(&mut chars, '(', ')');
                    let alts = split_alternatives(&inner);
                    result.push_str("(?:");
                    for (i, alt) in alts.iter().enumerate() {
                        if i > 0 {
                            result.push('|');
                        }
                        result.push_str(&pattern_to_regex(alt));
                    }
                    result.push(')');
                }
                '[' => {
                    let inner = collect_group(&mut chars, '[', ']');
                    let alts = split_alternatives(&inner);
                    result.push_str("(?:");
                    for (i, alt) in alts.iter().enumerate() {
                        if i > 0 {
                            result.push('|');
                        }
                        result.push_str(&pattern_to_regex(alt));
                    }
                    result.push_str(")?");
                }
                _ => {
                    let mut literal = String::new();
                    literal.push(c);
                    while let Some(&next) = chars.peek() {
                        if next == '(' || next == '[' {
                            break;
                        }
                        literal.push(chars.next().unwrap());
                    }
                    result.push_str(&escape(&literal));
                }
            }
        }
        result
    }

    fn collect_group(
        chars: &mut std::iter::Peekable<std::str::Chars>,
        open: char,
        close: char,
    ) -> String {
        let mut inner = String::new();
        let mut depth = 1;
        while let Some(&next) = chars.peek() {
            if next == open {
                depth += 1;
            } else if next == close {
                depth -= 1;
                if depth == 0 {
                    chars.next();
                    break;
                }
            }
            inner.push(chars.next().unwrap());
        }
        inner
    }

    fn split_alternatives(s: &str) -> Vec<String> {
        let mut alts = Vec::new();
        let mut current = String::new();
        let mut depth = 0;

        for c in s.chars() {
            match c {
                '(' | '[' => {
                    depth += 1;
                    current.push(c);
                }
                ')' | ']' => {
                    depth -= 1;
                    current.push(c);
                }
                '|' if depth == 0 => {
                    alts.push(current);
                    current = String::new();
                }
                _ => {
                    current.push(c);
                }
            }
        }
        if !current.is_empty() {
            alts.push(current);
        }
        alts
    }

    let mut regex_parts = Vec::new();
    for token in tokens {
        match token {
            Token::Literal(s) => {
                regex_parts.push(pattern_to_regex(s));
            }
            Token::Parameter(p) => {
                let param_name = &p[1..p.len() - 1];
                let is_wildcard = lists
                    .and_then(|l| l.get(param_name))
                    .and_then(|list| list.wildcard)
                    .unwrap_or(false);
                if is_wildcard { // match anything
                    regex_parts.push("(.*)".to_string());
                } else {
                    regex_parts.push("\\b([^ ]+)\\b".to_string());
                }
            }
        }
    }
    format!("^{}$", regex_parts.concat())
}


pub fn make_entity_resolver(data: Option<&HashMap<String, List>>, list_name: &str) -> String {
    let mut result = String::new();
    if let Some(lists) = data {
        if let Some(list) = lists.get(list_name) {
            if let Some(values) = &list.values {
                for vm in values {
                    let variants = expand_list_input_variants(&vm.r#in);
                    for variant in variants {
                        result.push_str(&format!("    \"{}\") echo \"{}\";;\n", variant, vm.out));
                    }
                }
            }
        }
    }
    result
}


pub fn escape_md(s: &str) -> String {
    let replacements = [
        ("\\", "\\\\"),
        ("*", "\\*"),
        ("`", "\\`"),
        ("_", "\\_"),
        ("[", "\\["),
        ("]", "\\]"),
    ];
    let mut result = s.to_string();
    for (from, to) in &replacements {
        result = result.replace(from, to);
    }
    result
}


pub fn make_timer_name(script_name: &str, time_str: &str) -> String {
    let safe_time = time_str.replace(':', "-");
    format!("yo-{}-at-{}", script_name, safe_time)
}


pub fn count_generated_patterns(script: &Script) -> usize {
    if let Some(voice) = &script.voice {
        let mut patterns = 0;
        for sentence in &voice.sentences {
            patterns += expand_optional_words(sentence).len();
        }
        patterns
    } else {
        0
    }
}

fn extract_param_names(sentence: &str) -> Vec<String> {
    let mut names = Vec::new();
    let mut remaining = sentence;
    while let Some(start) = remaining.find('{') {
        if let Some(end) = remaining[start..].find('}') {
            let param = &remaining[start + 1..start + end];
            names.push(param.to_string());
            remaining = &remaining[start + end + 1..];
        } else {
            break;
        }
    }
    names
}


pub fn count_understood_phrases(script: &Script) -> usize {
    let Some(voice) = &script.voice else { return 0 };
    let mut total = 0;
    for sentence in &voice.sentences {
        let expanded = expand_optional_words(sentence);
        for expanded_sentence in expanded {
            let param_names = extract_param_names(&expanded_sentence);
            if param_names.is_empty() {
                total += 1;
            } else {
                let mut product = 1;
                for name in &param_names {
                    if let Some(lists) = &voice.lists {
                        if let Some(list) = lists.get(name) {
                            if let Some(values) = &list.values {
                                product *= values.len();
                            }
                        }
                    }
                }
                total += product;
            }
        }
    }
    total
}


pub fn count_total_generated_patterns(scripts: &HashMap<String, Script>) -> usize {
    scripts.values().map(count_generated_patterns).sum()
}


pub fn count_total_understood_phrases(scripts: &HashMap<String, Script>) -> usize {
    scripts.values().map(count_understood_phrases).sum()
}


fn convert_script_config(config: ScriptConfig) -> (String, Script) {
    let name = config.name;
    let script = Script {
        description: config.description,
        category: config.category,
        parameters: config.parameters.unwrap_or_default(),
        code: config.code,
        binary: config.binary,
        aliases: config.aliases.unwrap_or_default(),
        log_level: config.log_level.unwrap_or_else(|| "INFO".to_string()),
        auto_start: config.auto_start.unwrap_or(false),
        run_every: config.run_every,
        run_at: config.run_at.unwrap_or_default(),
        voice: config.voice,
        visible_in_readme: config.visible_in_readme.unwrap_or(true),
        help_footer: config.help_footer,
    };
    (name, script)
}

fn generate_intent_data(scripts: &HashMap<String, Script>) -> serde_json::Value {
    let mut intent_map = serde_json::Map::new();

    for (name, script) in scripts {
        if let Some(voice) = &script.voice {
            let mut all_expanded = Vec::new();
            for sentence in &voice.sentences {
                all_expanded.extend(expand_optional_words(sentence));
            }
            all_expanded.sort();
            all_expanded.dedup();

            let mut substitutions = Vec::new();
            if let Some(lists) = &voice.lists {
                for list in lists.values() {
                    if let Some(values) = &list.values {
                        for vm in values {
                            let variants = expand_list_input_variants(&vm.r#in);
                            for variant in variants {
                                let pattern = if variant.contains(' ') {
                                    variant.clone()
                                } else {
                                    format!("({})", variant)
                                };
                                substitutions.push(serde_json::json!({
                                    "pattern": pattern,
                                    "value": vm.out
                                }));
                            }
                        }
                    }
                }
            }


            let lists_json = serde_json::to_value(&voice.lists).unwrap_or(serde_json::Value::Null);

            intent_map.insert(
                name.clone(),
                serde_json::json!({
                    "sentences": all_expanded,
                    "substitutions": substitutions,
                    "lists": lists_json,
                }),
            );
        }
    }

    serde_json::Value::Object(intent_map)
}


fn generate_fuzzy_index(scripts: &HashMap<String, Script>) -> Vec<serde_json::Value> {
    let mut entries = Vec::new();

    for (name, script) in scripts {
        if let Some(voice) = &script.voice {
            for sentence in &voice.sentences {
                for expanded in expand_optional_words(sentence) {
                    let mut words: Vec<_> = expanded
                        .to_lowercase()
                        .split_whitespace()
                        .map(String::from)
                        .collect();
                    words.sort();
                    let signature = words.join("|");

                    entries.push(serde_json::json!({
                        "script": name,
                        "sentence": expanded,
                        "signature": signature,
                    }));
                }
            }
        }
    }
    entries
}


fn generate_scripts_metadata(scripts: &HashMap<String, Script>) -> Vec<serde_json::Value> {
    scripts
        .iter()
        .map(|(name, script)| {
            serde_json::json!({
                "name": name,
                "description": script.description,
                "category": script.category,
                "parameters": script.parameters,
                "code": script.code,
                "binary": script.binary,
                "aliases": script.aliases,
                "log_level": script.log_level,
                "auto_start": script.auto_start,
                "run_every": script.run_every,
                "run_at": script.run_at,
                "visible_in_readme": script.visible_in_readme,
                "help_footer": script.help_footer,
            })
        })
        .collect()
}


/// Legacy matcher generation
fn build_substitutions(voice: &VoiceConfig) -> Vec<(String, String)> {
    let mut subs = Vec::new();
    if let Some(lists) = &voice.lists {
        for list in lists.values() {
            if let Some(values) = &list.values {
                for vm in values {
                    let variants = expand_list_input_variants(&vm.r#in);
                    for variant in variants {
                        subs.push((variant, vm.out.clone()));
                    }
                }
            }
        }
    }
    subs
}

/// Sanitize Bash variable name (replace "-" with "_")
fn sanitize_bash_var(name: &str) -> String {
    name.replace('-', "_")
}

/// generate a Bash function that matches a single script.
fn generate_matcher_code(script_name: &str, voice: &VoiceConfig, subs: &[(String, String)]) -> String {
    let mut code = String::new();
    code.push_str(&format!("match_{}() {{\n", script_name));
    code.push_str("    local input=\"$(echo \"$1\" | tr '[:upper:]' '[:lower:]')\"\n");

    if !subs.is_empty() {
        code.push_str("    declare -A substitutions\n");
        for (variant, out) in subs {
            let escaped_var = variant.replace('\'', "'\\''");
            code.push_str(&format!("    substitutions['{}']='{}'\n", escaped_var, out));
        }
    }

    /// generate a regex block for each expanded sentence
    for sentence in &voice.sentences {
        for expanded in expand_optional_words(sentence) {
            let regex = expand_to_regex(&expanded, voice.lists.as_ref());
            let escaped_regex = regex.replace('\'', "'\\''");
            code.push_str(&format!("    local regex='{}'\n", escaped_regex));
            code.push_str("    if [[ \"$input\" =~ $regex ]]; then\n");

            let param_names = extract_param_names(&expanded);
            for (i, raw_name) in param_names.iter().enumerate() {
                let safe_name = sanitize_bash_var(raw_name);
                let idx = i + 1;
                code.push_str(&format!("        local param_{}=\"${{BASH_REMATCH[{}]}}\"\n", safe_name, idx));
                // apply subs
                code.push_str(&format!("        if [[ -v substitutions[\"${{param_{}}}\"] ]]; then\n", safe_name));
                code.push_str(&format!("            param_{}=\"${{substitutions[\"${{param_{}}}\"]}}\"\n", safe_name, safe_name));
                code.push_str("        fi\n");

                /// validate against list values if not wildcard
                if let Some(list) = voice.lists.as_ref().and_then(|l| l.get(raw_name)) {
                    if !list.wildcard.unwrap_or(false) && list.values.is_some() {
                        let resolver = make_entity_resolver(voice.lists.as_ref(), raw_name);
                        code.push_str(&format!("        case \"${{param_{}}}\" in\n", safe_name));
                        code.push_str(&resolver);
                        code.push_str("        esac\n");
                    }
                }

                code.push_str(&format!("        declare -g _param_{}=\"${{param_{}}}\"\n", raw_name, safe_name));
            }

            /// build cmd_args array
            code.push_str("        cmd_args=()\n");
            for raw_name in &param_names {
                let safe_name = sanitize_bash_var(raw_name);
                code.push_str(&format!("        cmd_args+=(--{} \"${{param_{}}}\")\n", raw_name, safe_name));
            }
            code.push_str("        return 0\n");
            code.push_str("    fi\n");
        }
    }

    code.push_str("    return 1\n");
    code.push_str("}\n");
    code
}

/// generate all matcher scripts and the loader
fn generate_matchers(scripts: &HashMap<String, Script>, output_dir: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let matchers_dir = output_dir.join("matchers");
    fs::create_dir_all(&matchers_dir)?;
    let mut loader_lines = Vec::new();

    for (name, script) in scripts {
        if let Some(voice) = &script.voice {
            let subs = build_substitutions(voice);
            let matcher_code = generate_matcher_code(name, voice, &subs);
            let matcher_path = matchers_dir.join(format!("{}.sh", name));
            fs::write(&matcher_path, matcher_code)?;
            loader_lines.push(format!("source {}", matcher_path.display()));
        }
    }

    let loader_path = output_dir.join("matcher-loader.sh");
    fs::write(loader_path, loader_lines.join("\n"))?;
    Ok(())
}


fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = std::env::args().collect();

    let config_dir: Option<PathBuf> = if args.iter().any(|a| a == "--config-dir") {
        let pos = args.iter().position(|a| a == "--config-dir").unwrap();
        if pos + 1 >= args.len() {
            eprintln!("Missing argument for --config-dir");
            std::process::exit(1);
        }
        Some(PathBuf::from(&args[pos + 1]))
    } else {
        None
    };

    let config_path: Option<PathBuf> = if args.iter().any(|a| a == "--config") {
        if config_dir.is_some() {
            eprintln!("Cannot use both --config and --config-dir");
            std::process::exit(1);
        }
        let pos = args.iter().position(|a| a == "--config").unwrap();
        if pos + 1 >= args.len() {
            eprintln!("Missing argument for --config");
            std::process::exit(1);
        }
        Some(PathBuf::from(&args[pos + 1]))
    } else {
        None
    };

    let output_dir = if let Some(pos) = args.iter().position(|a| a == "--output") {
        if pos + 1 >= args.len() {
            eprintln!("Missing argument for --output");
            std::process::exit(1);
        }
        PathBuf::from(&args[pos + 1])
    } else { PathBuf::from("/etc/yo") };

    let config_sources: Vec<PathBuf> = if let Some(dir) = config_dir {
        let entries = fs::read_dir(&dir)?;
        let mut files: Vec<PathBuf> = entries
            .filter_map(|e| e.ok())
            .filter(|e| e.path().extension().and_then(|ext| ext.to_str()) == Some("toml"))
            .map(|e| e.path())
            .collect();
        if files.is_empty() {
            eprintln!("No .toml files found in directory: {}", dir.display());
            std::process::exit(1);
        }
        files.sort();
        files
    } else if let Some(path) = config_path {
        vec![path]
    } else {
        let default = dirs::config_dir()
            .ok_or("Could not find config directory")?
            .join("yo")
            .join("config.toml");
        if !default.exists() {
            eprintln!("Default config file not found: {}", default.display());
            eprintln!("Please create one or specify --config / --config-dir");
            std::process::exit(1);
        }
        vec![default]
    };

    let mut merged_split_words = Vec::new();
    let mut merged_sorry_phrases = Vec::new();
    let mut merged_scripts = Vec::new();
    let mut script_names = HashSet::new();

    for path in &config_sources {
        eprintln!("Reading configuration from: {}", path.display());
        let content = fs::read_to_string(path)?;
        let cfg: Config = toml::from_str(&content)?;

        if let Some(words) = cfg.split_words {
            for w in words {
                if !merged_split_words.contains(&w) {
                    merged_split_words.push(w);
                }
            }
        }

        if let Some(phrases) = cfg.sorry_phrases {
            for p in phrases {
                if !merged_sorry_phrases.contains(&p) {
                    merged_sorry_phrases.push(p);
                }
            }
        }

        for script_cfg in cfg.scripts {
            if script_names.contains(&script_cfg.name) {
                eprintln!("Duplicate script name '{}' found in {}", script_cfg.name, path.display());
                std::process::exit(1);
            }
            script_names.insert(script_cfg.name.clone());
            merged_scripts.push(script_cfg);
        }
    }

    let merged_config = Config {
        split_words: if merged_split_words.is_empty() { None } else { Some(merged_split_words) },
        sorry_phrases: if merged_sorry_phrases.is_empty() { None } else { Some(merged_sorry_phrases) },
        scripts: merged_scripts,
    };


    let mut scripts = HashMap::new();
    for script_cfg in merged_config.scripts {
        let (name, script) = convert_script_config(script_cfg);
        scripts.insert(name, script);
    }

    let intent_data = generate_intent_data(&scripts);
    let fuzzy_index = generate_fuzzy_index(&scripts);
    let scripts_metadata = generate_scripts_metadata(&scripts);

    fs::create_dir_all(&output_dir)?;

    fs::write(
        output_dir.join("intent-data.json"),
        serde_json::to_string_pretty(&intent_data)?,
    )?;
    fs::write(
        output_dir.join("fuzzy-index.json"),
        serde_json::to_string_pretty(&fuzzy_index)?,
    )?;
    fs::write(
        output_dir.join("scripts.json"),
        serde_json::to_string_pretty(&scripts_metadata)?,
    )?;

    if let Some(split_words) = merged_config.split_words {
        fs::write(
            output_dir.join("split-words.json"),
            serde_json::to_string_pretty(&split_words)?,
        )?;
    }
    if let Some(sorry_phrases) = merged_config.sorry_phrases {
        fs::write(
            output_dir.join("sorry-phrases.json"),
            serde_json::to_string_pretty(&sorry_phrases)?,
        )?;
    }

    generate_matchers(&scripts, &output_dir)?;

    let total_patterns = count_total_generated_patterns(&scripts);
    let total_phrases = count_total_understood_phrases(&scripts);
    eprintln!("Compilation successful!");
    eprintln!("Output directory: {}", output_dir.display());
    eprintln!("Total scripts with voice: {}", scripts.values().filter(|s| s.voice.is_some()).count());
    eprintln!("Generated patterns: {}", total_patterns);
    eprintln!("Understandable phrases: {}", total_phrases);

    Ok(())
}
