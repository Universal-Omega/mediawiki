#! /bin/bash

mkdir -p srv/mediawiki

cd srv/mediawiki

composer self-update --1

/usr/bin/git clone https://github.com/miraheze/mw-config.git config --depth=1

/usr/bin/git clone https://github.com/miraheze/mediawiki.git w --depth=1

cd w

cat <<'EOT' >> composer.local.json
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

composer install
php maintenance/install.php --dbtype sqlite --dbuser root --dbname mw --dbpath $(pwd) --pass AdminPassword WikiName AdminUser

rm LocalSettings.php
cd ..
mv config/LocalSettings.php w/LocalSettings.php
cd w

#echo -e "<?php set_include_path( get_include_path() . PATH_SEPARATOR . '/home/runner/work/mediawiki/mediawiki' ); ?>\n$(cat LocalSettings.php)" > LocalSettings.php

sed -i -e 's//srv//home/runner/work/mediawiki/mediawiki//g' LocalSettings.php

echo 'error_reporting(E_ALL| E_STRICT);' >> LocalSettings.php
echo 'ini_set("display_errors", 1);' >> LocalSettings.php
echo '$wgShowExceptionDetails = true;' >> LocalSettings.php
echo '$wgShowDBErrorBacktrace = true;' >> LocalSettings.php
echo '$wgDevelopmentWarnings = true;' >> LocalSettings.php

tail -n5 LocalSettings.php

php maintenance/update.php
