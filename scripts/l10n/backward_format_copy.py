# This script, instead of converting directly from json->arb, reads the manually
# altered English arb file, and looks up the values in the original json file.
# This allows for the manual modifications to be preserved, while still allowing
# for the automatic conversion of the keys. The new arb file will need to be
# manually adjusted.

import json
import os

SOURCE_ARB_FILE = '../noterly/lib/l10n/app_en.arb'

LANGUAGE_JSON_FOLDER = '../noterly/assets/i18n'

OUTPUT_FOLDER = 'l10n/out/backward_format_copy'


def json_to_arb_key(key):
    # page.active_notifications.title -> page_activeNotifications_title
    key_parts = key.split('.')
    new_key_parts = []

    for part in key_parts:
        if '_' in part:
            new_part = part.split('_')[0].lower() + ''.join([p.capitalize() for p in part.split('_')[1:]])
        else:
            new_part = part
        
        new_key_parts.append(new_part)

    return '_'.join(new_key_parts)

def arb_to_json_key(key):
    # page_activeNotifications_title -> page.active_notifications.title
    key_parts = key.split('_')
    new_key_parts = []

    for part in key_parts:
        for letter in part:
            if letter.isupper():
                part = part.replace(letter, f'_{letter.lower()}')
            
        new_key_parts.append(part)

    return '.'.join(new_key_parts)

def load_language_file(language_file):
    if not language_file.endswith('.json'):
        return

    language_code = language_file.split('.')[0]

    with open(f'{LANGUAGE_JSON_FOLDER}/{language_file}', 'r', encoding='utf-8') as f:
        return (language_code, json.load(f))

def escape_string(content):
    return content.replace("'", "''")

def convert_format(language_code, language_content):
    new_json = {}

    for arb_key in arb_content.keys():
        if arb_key.startswith('@'):
            # special key - copy from source
            new_json[arb_key] = arb_content[arb_key]
            continue

        json_key = arb_to_json_key(arb_key)
        
        if json_key in language_content:
            string = escape_string(language_content[json_key])
            new_json[arb_key] = string
        else:
            new_json[arb_key] = '**MISSING**'

    return new_json


language_json_contents = {}
new_arb_contents = {}


with open(SOURCE_ARB_FILE, 'r', encoding='utf-8') as f:
    arb_content = json.load(f)


for language_file in os.listdir(LANGUAGE_JSON_FOLDER):
    code, content = load_language_file(language_file)
    language_json_contents[code] = content
    

for language_code, language_content in language_json_contents.items():
    print(f'Converting {language_code}...')
    new_arb_contents[language_code] = convert_format(language_code, language_content)


for language_code, language_content in new_arb_contents.items():
    with open(f'{OUTPUT_FOLDER}/{language_code}.arb', 'w', encoding='utf-8') as f:
        json.dump(language_content, f)