use regex::escape;
use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet};
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};


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


fn escape_md(s: &str) -> String {
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

fn expand_optional_words(sentence: &str) -> Vec<String> {
    // placeholder
    vec![sentence.to_string()]
}

fn expand_list_input_variants(value: &str) -> Vec<String> {
    // placeholder
    vec![value.to_string()]
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


fn sanitize_var_name(name: &str) -> String {
    name.replace('-', "_")
}

fn generate_env_exports(script: &Script) -> String {
    let mut exports = Vec::new();
    for param in &script.parameters {
        if let Some(default) = &param.default {
            let value = match param.param_type.as_deref() {
                Some("string") | Some("path") => format!("'{}'", default.as_str().unwrap_or("")),
                Some("int") => default.to_string(),
                Some("bool") => {
                    if default.as_bool().unwrap_or(false) {
                        "true".to_string()
                    } else {
                        "false".to_string()
                    }
                }
                _ => default.to_string(),
            };
            exports.push(format!("export {}=\"{}\"", sanitize_var_name(&param.name), value));
        }
    }
    exports.join("\n")
}

fn generate_script_content(name: &str, script: &Script) -> String {
    let mut content = String::new();

    content.push_str("#!/usr/bin/env bash\n");
    content.push_str("set -o noglob\n\n");

    // environment injection (defaults)
    content.push_str(&generate_env_exports(script));
    content.push_str("\n\n");

    // setup ducktrace logging
    content.push_str("export DT_LOG_PATH=\"$HOME/.config/duckTrace/\"\n");
    content.push_str("mkdir -p \"$DT_LOG_PATH\"\n");
    content.push_str(&format!("export DT_LOG_FILE=\"{}.log\"\n", name));
    content.push_str("touch \"$DT_LOG_PATH/$DT_LOG_FILE\"\n");
    content.push_str(&format!("export DT_LOG_LEVEL=\"{}\"\n", script.log_level));
    content.push_str("\n");

    // verbose and dry-run flags
    content.push_str("VERBOSE=0\n");
    content.push_str("DRY_RUN=false\n");
    content.push_str("FILTERED_ARGS=()\n");
    content.push_str("while [[ $# -gt 0 ]]; do\n");
    content.push_str("  case \"$1\" in\n");
    content.push_str("    \\?) ((VERBOSE++)); shift ;;\n");
    content.push_str("    '!') DRY_RUN=true; shift ;;\n");
    content.push_str("    *) FILTERED_ARGS+=(\"$1\"); shift ;;\n");
    content.push_str("  esac\n");
    content.push_str("done\n");
    content.push_str("export VERBOSE DRY_RUN\n");
    content.push_str("set -- \"${FILTERED_ARGS[@]}\"\n");
    content.push_str("if [ \"$VERBOSE\" -ge 1 ]; then DT_LOG_LEVEL=\"DEBUG\"; fi\n\n");

    // parameter parsing
    content.push_str("declare -A PARAMS=()\n");
    content.push_str("POSITIONAL=()\n");
    content.push_str("while [[ $# -gt 0 ]]; do\n");
    content.push_str("  case \"$1\" in\n");
    content.push_str("    --help|-h)\n");
    content.push_str(&generate_help_section(name, script));
    content.push_str("      ;;\n");
    content.push_str("    --*)\n");
    content.push_str("      param_name=\"${1##--}\"\n");
    // check boolean params
    let bool_params: Vec<&str> = script.parameters
        .iter()
        .filter(|p| p.param_type.as_deref() == Some("bool"))
        .map(|p| p.name.as_str())
        .collect();
    if !bool_params.is_empty() {
        content.push_str(&format!(
            "      if [[ \" {params} \" =~ \" $param_name \" ]]; then\n",
            params = bool_params.join(" ")
        ));
        content.push_str("        if [[ $# -gt 1 && ( \"$2\" == \"true\" || \"$2\" == \"false\" ) ]]; then\n");
        content.push_str("          PARAMS[\"$param_name\"]=\"$2\"\n");
        content.push_str("          shift 2\n");
        content.push_str("        else\n");
        content.push_str("          PARAMS[\"$param_name\"]=\"true\"\n");
        content.push_str("          shift 1\n");
        content.push_str("        fi\n");
        content.push_str("      else\n");
    }
    // regular parameters
    content.push_str("        if [[ \" ${params} \" =~ \" $param_name \" ]]; then\n");
    content.push_str("          PARAMS[\"$param_name\"]=\"$2\"\n");
    content.push_str("          shift 2\n");
    content.push_str("        else\n");
    content.push_str("          echo -e \"\\033[1;31m 🦆 duck say ⮞ fuck ❌ $1\\033[0m Unknown parameter: $1\"\n");
    content.push_str("          exit 1\n");
    content.push_str("        fi\n");
    if !bool_params.is_empty() {
        content.push_str("      fi\n");
    }
    content.push_str("      ;;\n");
    content.push_str("    *)\n");
    content.push_str("      POSITIONAL+=(\"$1\")\n");
    content.push_str("      shift\n");
    content.push_str("      ;;\n");
    content.push_str("  esac\n");
    content.push_str("done\n\n");

    // Assign parameters from positional and named
    for (idx, param) in script.parameters.iter().enumerate() {
        let var = sanitize_var_name(&param.name);
        content.push_str(&format!(
            "if (( {} < ${{#POSITIONAL[@]}} )); then\n",
            idx
        ));
        content.push_str(&format!("  {}=\"${{POSITIONAL[{}]}}\"\n", var, idx));
        content.push_str("fi\n");
    }
    for param in &script.parameters {
        let var = sanitize_var_name(&param.name);
        content.push_str(&format!(
            "if [[ -n \"${{PARAMS[{}]:-}}\" ]]; then\n",
            param.name
        ));
        content.push_str(&format!("  {}=\"${{PARAMS[{}]}}\"\n", var, param.name));
        content.push_str("fi\n");
    }
    content.push_str("\n");

    // parameter count validation
    if !script.parameters.is_empty() {
        content.push_str(&format!(
            "if [ ${{#POSITIONAL[@]}} -gt {} ]; then\n",
            script.parameters.len()
        ));
        content.push_str("  echo -e \"\\033[1;31m 🦆 duck say ⮞ fuck ❌ Too many arguments\\033[0m\" >&2\n");
        content.push_str("  exit 1\n");
        content.push_str("fi\n\n");
    }

    // Type validation
    for param in &script.parameters {
        if let Some(ty) = &param.param_type {
            if ty != "string" {
                let var = sanitize_var_name(&param.name);
                content.push_str(&format!("if [ -n \"${{{}}}\" ]; then\n", var));
                match ty.as_str() {
                    "int" => {
                        content.push_str(&format!(
                            "  if ! [[ \"${{{}}}\" =~ ^[0-9]+$ ]]; then\n",
                            var
                        ));
                        content.push_str(&format!(
                            "    echo -e \"\\033[1;31m 🦆 duck say ⮞ fuck ❌ {} --{} must be integer\\033[0m\" >&2\n",
                            name, param.name
                        ));
                        content.push_str("    exit 1\n");
                        content.push_str("  fi\n");
                    }
                    "bool" => {
                        content.push_str(&format!(
                            "  if ! [[ \"${{{}}}\" =~ ^(true|false)$ ]]; then\n",
                            var
                        ));
                        content.push_str(&format!(
                            "    echo -e \"\\033[1;31m 🦆 duck say ⮞ fuck ❌ {} --{} must be true or false\\033[0m\" >&2\n",
                            name, param.name
                        ));
                        content.push_str("    exit 1\n");
                        content.push_str("  fi\n");
                    }
                    "path" => {
                        content.push_str(&format!(
                            "  if ! [ -e \"${{{}}}\" ]; then\n",
                            var
                        ));
                        content.push_str(&format!(
                            "    echo -e \"\\033[1;31m 🦆 duck say ⮞ fuck ❌ {} Path not found: ${{{}}}\\033[0m\" >&2\n",
                            name, var
                        ));
                        content.push_str("    exit 1\n");
                        content.push_str("  fi\n");
                    }
                    _ => {}
                }
                content.push_str("fi\n");
            }
        }
    }

    // Values validation (allowed list)
    for param in &script.parameters {
        if let Some(values) = &param.values {
            if param.param_type.as_deref().unwrap_or("string") == "string" {
                let var = sanitize_var_name(&param.name);
                content.push_str(&format!("if [ -n \"${{{}}}\" ]; then\n", var));
                let allowed = values
                    .iter()
                    .map(|v| format!("'{}'", v.replace('\'', "'\\''")))
                    .collect::<Vec<_>>()
                    .join(" ");
                content.push_str(&format!("  allowed_values=({})\n", allowed));
                content.push_str("  value_found=false\n");
                content.push_str("  for allowed in \"${allowed_values[@]}\"; do\n");
                content.push_str(&format!("    if [[ \"${{{}}}\" == \"$allowed\" ]]; then\n", var));
                content.push_str("      value_found=true\n");
                content.push_str("      break\n");
                content.push_str("    fi\n");
                content.push_str("  done\n");
                content.push_str("  if [[ \"$value_found\" == \"false\" ]]; then\n");
                content.push_str(&format!(
                    "    echo -e \"\\033[1;31m 🦆 duck say ⮞ fuck ❌ {} --{} must be one of: {}\\033[0m\" >&2\n",
                    name, param.name, values.join(", ")
                ));
                content.push_str("    exit 1\n");
                content.push_str("  fi\n");
                content.push_str("fi\n");
            }
        }
    }

    // defaults for boolean & other types
    for param in &script.parameters {
        if let Some(default) = &param.default {
            if param.param_type.as_deref() == Some("bool") {
                let var = sanitize_var_name(&param.name);
                let def_str = if default.as_bool().unwrap_or(false) {
                    "true"
                } else {
                    "false"
                };
                content.push_str(&format!(
                    "if [[ -z \"${{{var:-}}}\" ]]; then {var}=\"{def_str}\"; fi\n"
                ));
            } else {
                let var = sanitize_var_name(&param.name);
                    let def_str = match param.param_type.as_deref() {
                        Some("string") | Some("path") => format!("'{}'", default.as_str().unwrap_or("")),
                        Some("int") => default.to_string(),
                        Some("bool") => {
                            (if default.as_bool().unwrap_or(false) { "true" } else { "false" }).to_string()
                        }
                        _ => default.to_string(),  // ← no .as_str(), just a String
                    };
                content.push_str(&format!(
                    "if [[ -z \"${{{var:-}}}\" ]]; then {var}={def_str}; fi\n"
                ));
            }
        }
    }

    // Required parameters check
    for param in &script.parameters {
        if !param.optional.unwrap_or(false) && param.default.is_none() {
            let var = sanitize_var_name(&param.name);
            content.push_str(&format!(
                "if [[ -z \"${{{var:-}}}\" ]]; then\n"
            ));
            content.push_str(&format!(
                "  echo -e \"\\033[1;31m 🦆 duck say ⮞ fuck ❌ {} Missing required parameter: {}\\033[0m\" >&2\n",
                name, param.name
            ));
            content.push_str("  exit 1\n");
            content.push_str("fi\n");
        }
    }

    // execution
    if let Some(binary) = &script.binary {
        content.push_str("args=()\n");
        for param in &script.parameters {
            let var = sanitize_var_name(&param.name);
            content.push_str(&format!(
                "if [[ -n \"${{{var:-}}}\" ]]; then args+=(--{} \"${{{var}}}\"); fi\n",
                param.name
            ));
        }
        content.push_str(&format!("exec {} \"${{args[@]}}\"\n", binary));
    } else if let Some(code) = &script.code {
        content.push_str(code);
        content.push_str("\n");
    }

    content
}

fn generate_help_section(name: &str, script: &Script) -> String {
    let mut help = String::new();
    help.push_str("      width=$(tput cols 2>/dev/null || echo 100)\n");
    if let Some(footer_cmd) = &script.help_footer {
        help.push_str(&format!("      help_footer=$({})\n", footer_cmd));
    } else {
        help.push_str("      help_footer=\"\"\n");
    }
    help.push_str("      usage_suffix=\"\"\n");
    if !script.parameters.is_empty() {
        help.push_str("      usage_suffix=\" [OPTIONS]\"\n");
    }
    help.push_str("      cat <<'EOF' | glow --width \"$width\" -\n");
    help.push_str(&format!("# 🚀🦆 yo {}\n", escape_md(name)));
    help.push_str(&format!("{}\n", script.description));
    help.push_str(&format!("**Usage:** `yo {}`${{usage_suffix}}\n", escape_md(name)));
    if !script.parameters.is_empty() {
        help.push_str("\n## Parameters\n");
        for param in &script.parameters {
            help.push_str(&format!("**`--{}`**  \n", param.name));
            help.push_str(&format!("{}  \n", param.description.as_deref().unwrap_or("")));
            if param.optional.unwrap_or(false) {
                help.push_str("*(optional)* ");
            }
            if let Some(default) = &param.default {
                let def_str = match param.param_type.as_deref() {
                    Some("string") | Some("path") => format!("'{}'", default.as_str().unwrap_or("")),
                    Some("int") => default.to_string(),
                    Some("bool") => {
                        (if default.as_bool().unwrap_or(false) { "true" } else { "false" }).to_string()
                    }
                    _ => default.to_string(),  // ← no .as_str(), just a String
                };
                help.push_str(&format!("*(default: {})* ", def_str));
            }
            if let Some(values) = &param.values {
                if param.param_type.as_deref().unwrap_or("string") == "string" {
                    help.push_str(&format!("*(allowed: {})* ", values.join(", ")));
                }
            }
            help.push_str("\n\n");
        }
    }
    // voice help if any
    if let Some(voice) = &script.voice {
        if voice.enabled.unwrap_or(true) {
            let patterns = 0; // placeholder – compute if needed
            let phrases = 0;
            help.push_str("## Voice Commands\n\n");
            help.push_str(&format!("Patterns: {}  \n", patterns));
            help.push_str(&format!("Phrases: {}  \n\n", phrases));
            for sentence in &voice.sentences {
                help.push_str(&format!("- \"{}\"\n", sentence));
            }
        }
    }
    help.push_str("\n$help_footer\n");
    help.push_str("EOF\n");
    help.push_str("      exit 0\n");
    help
}


fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = std::env::args().collect();

    let config_dir = if args.len() > 1 {
        PathBuf::from(&args[1])
    } else {
        eprintln!("Usage: {} <config-dir> [output-dir]", args[0]);
        std::process::exit(1);
    };
    let output_dir = if args.len() > 2 {
        PathBuf::from(&args[2])
    } else {
        PathBuf::from("yo-scripts")
    };

    // read all .TOML files
    let mut scripts_map = HashMap::new();
    let entries = fs::read_dir(&config_dir)?;
    let mut toml_files: Vec<PathBuf> = entries
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().and_then(|ext| ext.to_str()) == Some("toml"))
        .map(|e| e.path())
        .collect();
    toml_files.sort();

    for path in &toml_files {
        eprintln!("Reading {}", path.display());
        let content = fs::read_to_string(path)?;
        let cfg: Config = toml::from_str(&content)?;
        for script_cfg in cfg.scripts {
            let (name, script) = convert_script_config(script_cfg);
            if scripts_map.contains_key(&name) {
                eprintln!("Duplicate script name: {}", name);
                std::process::exit(1);
            }
            scripts_map.insert(name, script);
        }
    }

    // create output dir
    let bin_dir = output_dir.join("bin");
    fs::create_dir_all(&bin_dir)?;

    // generate per‑script executables
    for (name, script) in &scripts_map {
        let script_path = bin_dir.join(format!("yo-{}", name));
        let content = generate_script_content(name, script);
        fs::write(&script_path, content)?;
        // make executable
        let mut perms = fs::metadata(&script_path)?.permissions();
        perms.set_mode(0o755);
        fs::set_permissions(&script_path, perms)?;

        // create symlinks for aliases
        for alias in &script.aliases {
            let link_path = bin_dir.join(format!("yo-{}", alias));
            let _ = fs::remove_file(&link_path); // remove if exists
            std::os::unix::fs::symlink(&script_path, &link_path)?;
        }
    }

    // generate the main `yo` wrapper
    let yo_wrapper_content = generate_yo_wrapper(&bin_dir, &scripts_map);
    let yo_path = bin_dir.join("yo");
    fs::write(&yo_path, yo_wrapper_content)?;
    let mut perms = fs::metadata(&yo_path)?.permissions();
    perms.set_mode(0o755);
    fs::set_permissions(&yo_path, perms)?;

    eprintln!("✅ Scripts generated in {}", output_dir.display());
    Ok(())
}

fn generate_yo_wrapper(bin_dir: &Path, scripts: &HashMap<String, Script>) -> String {
    let mut content = String::new();
    content.push_str("#!/usr/bin/env bash\n");
    content.push_str("set -o noglob\n\n");
    content.push_str("script_dir=\"$(cd \"$(dirname \"${BASH_SOURCE[0]}\")\" && pwd)\"\n");
    content.push_str("show_help() {\n");
    content.push_str("  cat <<'EOF'\n");
    content.push_str("### ──────⋆⋅☆☆☆⋅⋆────── ##\n");
    content.push_str("**Usage:** `yo <command> [arguments]`\n");
    content.push_str("### ──────⋆⋅☆☆☆⋅⋆────── ##\n");
    content.push_str("### 🦆✨ Available Commands\n");
    content.push_str("Parameters inside brackets are [optional]\n");
    content.push_str("| Command Syntax               | Aliases    | Description |\n");
    content.push_str("|------------------------------|------------|-------------|\n");

    // build table rows 
    for (name, script) in scripts {
        if !script.visible_in_readme {
            continue;
        }
        let alias_str = if script.aliases.is_empty() {
            String::new()
        } else {
            script.aliases.join(", ")
        };
        let param_hint: Vec<String> = script
            .parameters
            .iter()
            .map(|p| {
                if p.optional.unwrap_or(false) || p.default.is_some() {
                    format!("[--{}]", p.name)
                } else {
                    format!("--{}", p.name)
                }
            })
            .collect();
        let syntax = format!("`yo {} {}`", name, param_hint.join(" "));
        content.push_str(&format!(
            "| {} | {} | {} |\n",
            syntax, alias_str, script.description
        ));
    }
    content.push_str("EOF\n");
    content.push_str("  exit 0\n");
    content.push_str("}\n\n");
    content.push_str("if [[ $# -eq 0 ]]; then\n");
    content.push_str("  show_help\n");
    content.push_str("  exit 1\n");
    content.push_str("fi\n");
    content.push_str("case \"$1\" in\n");
    content.push_str("  -h|--help) show_help; exit 0 ;;\n");
    content.push_str("  *) command=\"$1\"; shift ;;\n");
    content.push_str("esac\n");
    content.push_str("script_path=\"$script_dir/yo-$command\"\n");
    content.push_str("if [[ -x \"$script_path\" ]]; then\n");
    content.push_str("  exec \"$script_path\" \"$@\"\n");
    content.push_str("else\n");
    content.push_str("  echo -e \"\\033[1;31m 🦆 duck say ⮞ fuck ❌ $1\\033[0m Error: Unknown command '$command'\" >&2\n");
    content.push_str("  show_help\n");
    content.push_str("  exit 1\n");
    content.push_str("fi\n");
    content
}
