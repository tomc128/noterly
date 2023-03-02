import json
import os
import shutil

# If set to True, the output will be also saved directly into the
# Flutter project directory.
SAVE_TO_FLUTTER = True

# If set to True, the output directory will be purged before
# generating the new files. This helps to remove any old files
# that are no longer needed.
PURGE_DIRECTORY = True

# If set to True, the "$include" key will be used to determine
# which languages to include in the output.
PARSE_INCLUDE = True

with open('i18n.json', 'r', encoding='utf-8') as f:
    i18n = json.load(f)

lang_data = {}

for key, value in i18n['Translations'].items():
    for lang, text in value.items():
        if lang not in lang_data:
            lang_data[lang] = {}

        if key.startswith('$'):
            # Ignore special keys
            continue

        if text is not None and text.strip() != '':
            lang_data[lang][key] = text
        else:
            # Empty text - no translation so ignore
            pass

if PARSE_INCLUDE:
    for lang, include in i18n['Translations']['$include'].items():
        if not include:
            # Remove the language
            lang_data.pop(lang, None)

# Remove any empty languages
lang_data = {lang: data for lang, data in lang_data.items() if len(data) > 0}

if PURGE_DIRECTORY:
    if os.path.exists('out'):
        shutil.rmtree('out')
    os.mkdir('out')
    
    if SAVE_TO_FLUTTER:
        if os.path.exists('../../noterly/assets/i18n'):
            shutil.rmtree('../../noterly/assets/i18n')
        os.mkdir('../../noterly/assets/i18n')


for lang, data in lang_data.items():
    with open(f'out/{lang}.json', 'w', encoding='utf-8') as f:
        json.dump(data, f)
    
    if SAVE_TO_FLUTTER:
        with open(f'../../noterly/assets/i18n/{lang}.json', 'w', encoding='utf-8') as f:
            json.dump(data, f)
