import json

base = json.load(open('lib/l10n/app_en.arb'))

langs = ['es', 'fr', 'de', 'ja', 'zh', 'ar', 'pt', 'ru']

for lang in langs:
    with open(f'lib/l10n/app_{lang}.arb', 'w') as f:
        json.dump(base, f, indent=2, ensure_ascii=False)
