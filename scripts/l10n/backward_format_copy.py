# This script, instead of converting directly from json->arb, reads the manually
# altered English arb file, and looks up the values in the original json file.
# This allows for the manual modifications to be preserved, while still allowing
# for the automatic conversion of the keys. The new arb file will need to be
# manually adjusted.

import json
import os
import re

from rich import print

MISSING_STRING = '**MISSING**'

TRUE_ARB_SOURCE_FILE = '../noterly/lib/l10n/app_en.arb'
GENERATED_ARB_SOURCE_FILE = 'l10n/out/initial_format_conversion/en.arb'

LANGUAGE_JSON_FOLDER = '../noterly/assets/i18n'

OUTPUT_FOLDER = 'l10n/out/backward_format_copy'


print('[bold]l10n backward format copy script[/bold]')
print(f'TRUE_ARB_SOURCE_FILE: [italic]{TRUE_ARB_SOURCE_FILE}[/italic]')
print(f'GENERATED_ARB_SOURCE_FILE: [italic]{GENERATED_ARB_SOURCE_FILE}[/italic]')
print(f'LANGUAGE_JSON_FOLDER: [italic]{LANGUAGE_JSON_FOLDER}[/italic]')
print(f'OUTPUT_FOLDER: [italic]{OUTPUT_FOLDER}[/italic]')
print(f'MISSING_STRING: [italic]{MISSING_STRING}[/italic]')
print()



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

def compare_and_fix_arb_strings(key, source_string, generated_string, new_string):
    # this is if we have changed a placeholder name, i.e.
    # generated_string: 'After {duration}'
    # source_string: 'After {durationString}'
    # so new_string will be 'After {duration}', we need to replace {duration} with {durationString}

    if '{' not in source_string:
        return new_string
    
    pattern = r'{\w+}'

    source_placeholders = re.findall(pattern, source_string)
    generated_placeholders = re.findall(pattern, generated_string)

    if len(source_placeholders) != len(generated_placeholders):
        print(f'[yellow]Warning: placeholder mismatch for {key}[/yellow]')
        return MISSING_STRING
    
    for i, source_placeholder in enumerate(source_placeholders):
        generated_placeholder = generated_placeholders[i]

        if source_placeholder != generated_placeholder:
            new_string = new_string.replace(generated_placeholder, source_placeholder)
    
    return new_string
    
def convert_format(language_code, language_content):
    new_content = {}
    num_fixes = 0

    for arb_key in arb_content.keys():
        if arb_key.startswith('@'):
            # special key - copy from source
            new_content[arb_key] = arb_content[arb_key]
            continue

        json_key = arb_to_json_key(arb_key)
        
        if json_key in language_content:
            string = escape_string(language_content[json_key])
            fixed_string = compare_and_fix_arb_strings(arb_key, arb_content[arb_key], generated_arb_content[arb_key], string)

            if fixed_string != string:
                num_fixes += 1
                string = fixed_string

            new_content[arb_key] = string
        else:
            new_content[arb_key] = MISSING_STRING

    new_content['@@locale'] = language_code

    print(f'[yellow]Fixed {num_fixes} strings for {language_code}[/yellow]')

    return new_content


language_json_contents = {}
new_arb_contents = {}

print('[blue]Loading arb data...[/blue]', end='')
with open(TRUE_ARB_SOURCE_FILE, 'r', encoding='utf-8') as f:
    arb_content = json.load(f)

with open(GENERATED_ARB_SOURCE_FILE, 'r', encoding='utf-8') as f:
    generated_arb_content = json.load(f)
print('[bold green]Done![/bold green]')


print('[blue]Loading JSON data...[/blue]', end='')
for language_file in os.listdir(LANGUAGE_JSON_FOLDER):
    code, content = load_language_file(language_file)
    language_json_contents[code] = content
print('[bold green]Done![/bold green]')
    

for language_code, language_content in language_json_contents.items():
    print(f'\n[blue]Converting {language_code}...[/blue]')
    new_arb_contents[language_code] = convert_format(language_code, language_content)
    print('[bold green]Done![/bold green]')


for language_code, language_content in new_arb_contents.items():
    with open(f'{OUTPUT_FOLDER}/{language_code}.arb', 'w', encoding='utf-8') as f:
        json.dump(language_content, f)

print('\n[bold green]All done![/bold green]')