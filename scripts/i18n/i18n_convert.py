import json

with open('i18n.json', 'r') as f:
    i18n = json.load(f)

lang_data = {}

for key, value in i18n['text'].items():
    for lang, text in value.items():
        if lang not in lang_data:
            lang_data[lang] = {}
        lang_data[lang][key] = text

for lang, data in lang_data.items():
    with open(f'out/{lang}.json', 'w') as f:
        json.dump(data, f)