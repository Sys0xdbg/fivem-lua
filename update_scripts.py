import os
import json
import re
import hashlib

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_URL = "https://sys0xdbg.github.io/fivem-lua/"

GAMES = {
    "fivem": {
        "scripts_dir": os.path.join(ROOT_DIR, "fivem", "scripts"),
        "json_path": os.path.join(ROOT_DIR, "fivemLuaScripts_items.json"),
    },
    "redm": {
        "scripts_dir": os.path.join(ROOT_DIR, "redm", "scripts"),
        "json_path": os.path.join(ROOT_DIR, "redmLuaScripts_items.json"),
    },
}

# Category keywords - order matters, first match wins
CATEGORIES = {
    "lynx": "Lynx",
    "brutan": "Brutan",
    "tiago": "Tiago",
    "malossi": "Malossi",
    "eulen": "Eulen",
    "absolute": "Absolute",
    "falcon": "Falcon",
    "exia": "Exia",
    "maestro": "Maestro",
    "hoax": "Hoax",
    "hydro": "Hydro",
    "cobra": "Cobra",
    "tito": "TITOModz",
    "ham": "Ham",
    "xaries": "Xaries",
    "aries": "Xaries",
    "bitizy": "Bitizy",
    "melon": "Melon",
    "fallout": "Fallout",
    "root": "Root",
    "rena": "Rena",
    "polstar": "Polstar",
    "dopamine": "Dopamine",
    "skid": "Skid",
    "wizard": "Wizard",
    "chocolat": "Chocolat",
    "chocola": "Chocolat",
    "shadow": "Shadow",
    "divine": "Divine",
    "infinity": "Infinity",
    "lumia": "Lumia",
    "luminous": "Luminous",
    "motion": "Motion",
    "wave": "Wave",
    "monster": "Monster",
    "red_menu": "Red Menu",
    "crusader": "Crusader",
    "crown": "Crown",
    "creek": "Creek",
    "oblivius": "Oblivius",
    "proxy": "Proxy",
}


def clean_filename(filename):
    """Clean up a messy filename into a consistent format."""
    name = filename.replace(".lua", "")

    # Remove common junk patterns
    name = re.sub(r'\[unknowncheats\.me\]', '', name)
    name = re.sub(r'Leaked\s*By\s*Mr\.?\s*Proxy', '', name, flags=re.IGNORECASE)
    name = re.sub(r'SPOILER_', '', name)
    name = re.sub(r'\(My Menu\)', '', name)
    name = re.sub(r'_+$', '', name)

    # Replace spaces, dashes, dots (not version dots) with underscores
    name = name.replace(" ", "_").replace("-", "_")

    # Remove parentheses but keep content
    name = name.replace("(", "_").replace(")", "")

    # Remove brackets
    name = name.replace("[", "").replace("]", "")

    # Lowercase
    name = name.lower()

    # Normalize version patterns: v1, v2.0, etc.
    name = re.sub(r'([a-z])(\d+\.\d+)', r'\1_v\2', name)
    name = re.sub(r'([a-z])(\d+)$', r'\1_v\2', name)
    name = re.sub(r'([a-z])(\d+)(_)', r'\1_v\2\3', name)

    # Avoid double "v" like "v_v2"
    name = re.sub(r'v_v(\d)', r'v\1', name)

    # Clean up multiple underscores
    name = re.sub(r'_+', '_', name)
    name = name.strip('_')

    return name + ".lua"


def detect_category(filename):
    """Detect the category based on filename keywords."""
    lower = filename.lower()
    for keyword, category in CATEGORIES.items():
        if keyword in lower:
            return category
    return "Other"


def make_display_name(filename):
    """Convert a clean filename into a readable display name."""
    name = filename.replace(".lua", "")
    parts = name.split("_")
    result = []
    for part in parts:
        if re.match(r'^v\d', part):
            result.append(part)
        else:
            result.append(part.capitalize())
    return " ".join(result)


def get_file_hash(filepath):
    """Get MD5 hash of a file for duplicate detection."""
    h = hashlib.md5()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def find_duplicates(scripts_dir, lua_files):
    """Find duplicate files by content hash. Returns set of files to remove."""
    hash_map = {}
    duplicates = set()
    for f in sorted(lua_files):
        filepath = os.path.join(scripts_dir, f)
        file_hash = get_file_hash(filepath)
        if file_hash in hash_map:
            duplicates.add(f)
        else:
            hash_map[file_hash] = f
    return duplicates


def process_game(game_name, scripts_dir, json_path):
    """Process a single game's scripts folder."""
    print(f"{'=' * 50}")
    print(f"  {game_name.upper()}")
    print(f"{'=' * 50}")

    # Ensure scripts directory exists
    if not os.path.isdir(scripts_dir):
        os.makedirs(scripts_dir)
        print(f"Created {scripts_dir}")

    # Get all lua files
    lua_files = [f for f in os.listdir(scripts_dir) if f.endswith(".lua")]

    if not lua_files:
        print(f"No .lua files found in {game_name}/scripts/\n")
        # Write empty JSON
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump([], f, indent=2)
        return

    print(f"Found {len(lua_files)} .lua files\n")

    # Step 1: Find and remove duplicates
    duplicates = find_duplicates(scripts_dir, lua_files)
    if duplicates:
        print(f"Found {len(duplicates)} duplicate(s):")
        for dup in sorted(duplicates):
            print(f"  Removing: {dup}")
            os.remove(os.path.join(scripts_dir, dup))
        lua_files = [f for f in lua_files if f not in duplicates]
        print()

    # Step 2: Clean filenames
    renames = {}
    for old_name in lua_files:
        new_name = clean_filename(old_name)
        if old_name != new_name:
            renames[old_name] = new_name

    if renames:
        print(f"Renaming {len(renames)} file(s):")
        for old_name, new_name in sorted(renames.items()):
            old_path = os.path.join(scripts_dir, old_name)
            new_path = os.path.join(scripts_dir, new_name)
            if os.path.exists(new_path) and old_name != new_name:
                print(f"  SKIP (conflict): {old_name} -> {new_name}")
                continue
            print(f"  {old_name} -> {new_name}")
            os.rename(old_path, new_path)
        print()

    # Refresh file list after renames
    lua_files = sorted([f for f in os.listdir(scripts_dir) if f.endswith(".lua")])

    # Step 3: Build JSON
    url_prefix = BASE_URL + game_name + "/scripts/"
    items = []
    category_counts = {}
    for filename in lua_files:
        category = detect_category(filename)
        display_name = make_display_name(filename)
        link = url_prefix + filename

        items.append({
            "name": display_name,
            "link": link,
            "catagory": category
        })

        category_counts[category] = category_counts.get(category, 0) + 1

    # Sort by category then name
    items.sort(key=lambda x: (x["catagory"] == "Other", x["catagory"], x["name"]))

    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(items, f, indent=2, ensure_ascii=False)

    print(f"Updated {os.path.basename(json_path)}")
    print(f"Total scripts: {len(items)}")
    print(f"\nCategories:")
    for cat in sorted(category_counts, key=lambda c: (c == "Other", c)):
        print(f"  {cat}: {category_counts[cat]}")
    print()


def main():
    for game_name, config in GAMES.items():
        process_game(game_name, config["scripts_dir"], config["json_path"])

    print("All done!")


if __name__ == "__main__":
    main()
