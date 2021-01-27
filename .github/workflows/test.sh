#! /bin/bash

mkdir -p srv/mediawiki
cd srv/mediawiki

/usr/bin/git clone https://github.com/miraheze/mw-config.git config --depth=1

/usr/bin/git clone https://github.com/miraheze/mediawiki.git w --recurse-submodules --depth=1

cd w

composer self-update --1
composer install
php maintenance/install.php --dbtype sqlite --dbuser root --dbname mw --dbpath $(pwd) --pass AdminPassword WikiName AdminUser

cat <<EOT >> composer.local.json
{
	"extra": {
		"merge-plugin": {
			"merge-dev": true,
			"include": [
				"extensions/Wikibase/composer.json",
				"extensions/Maps/composer.json",
				"extensions/Flow/composer.json",
				"extensions/OAuth/composer.json",
				"extensions/TemplateStyles/composer.json",
				"extensions/AntiSpoof/composer.json",
				"extensions/Kartographer/composer.json",
				"extensions/TimedMediaHandler/composer.json",
				"extensions/Translate/composer.json",
				"extensions/OATHAuth/composer.json",
				"extensions/Lingo/composer.json",
				"extensions/Validator/composer.json",
				"extensions/WikibaseQualityConstraints/composer.json",
				"extensions/WikibaseLexeme/composer.json",
				"extensions/CreateWiki/composer.json"
			]
		}
	}
}
EOT

rm LocalSettings.php
cd ..
mv config/LocalSettings.php w/LocalSettings.php
cd w

echo 'error_reporting(E_ALL| E_STRICT);' >> LocalSettings.php
echo 'ini_set("display_errors", 1);' >> LocalSettings.php
echo '$wgShowExceptionDetails = true;' >> LocalSettings.php
echo '$wgShowDBErrorBacktrace = true;' >> LocalSettings.php
echo '$wgDevelopmentWarnings = true;' >> LocalSettings.php

tail -n5 LocalSettings.php
