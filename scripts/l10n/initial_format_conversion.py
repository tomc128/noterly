import json

SOURCE_FILE = '../noterly/assets/i18n/en_GB.json'

OUTPUT_DIRECTORY = 'l10n/out/initial_format_conversion'

with open(SOURCE_FILE, 'r', encoding='utf-8') as f:
    source = json.load(f)


new_json = {}

for key in source:
    key_parts = key.split('.')
    new_key_parts = []

    for part in key_parts:
        if '_' in part:
            # convert to camel case with first letter lowercase
            new_part = part.split('_')[0].lower() + ''.join([p.capitalize() for p in part.split('_')[1:]])
        else:
            new_part = part
        
        new_key_parts.append(new_part)

    new_key = '_'.join(new_key_parts)
    
    new_json[new_key] = source[key]

with open(f'{OUTPUT_DIRECTORY}/en.arb', 'w', encoding='utf-8') as f:
    json.dump(new_json, f)