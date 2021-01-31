#! /bin/bash

mkdir -p srv/mediawiki

cd srv/mediawiki

composer self-update --1

cd w

composer install

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

mkdir data
chmod a+w data

php maintenance/install.php --dbtype=mysql --dbname=mediawiki --dbuser=root --dbpass=root --pass=AdminPassword WikiName AdminUser
#php maintenance/install.php --dbtype=sqlite --dbuser=root --dbname=mediawiki --dbpath=/home/runner/work/mediawiki/mediawiki/srv/mediawiki/w/data --pass=AdminPassword WikiName AdminUser

#sqlite3 /home/runner/work/mediawiki/mediawiki/srv/mediawiki/w/data/mediawiki.sqlite

cd ..

rm config/Database.php
mv w/LocalSettings.php config/Database.php

mv config/LocalSettings.php w/LocalSettings.php
mv config/ManageWikiExtensions.php w/ManageWikiExtensions.php
mv config/ManageWikiNamespaces.php w/ManageWikiNamespaces.php
mv config/ManageWikiSettings.php w/ManageWikiSettings.php

cd config

echo -n > PrivateSettings.php
echo -n > ExtensionMessageFiles.php

cd ..

cd w

sed -i -e 's/\/srv\//\/home\/runner\/work\/mediawiki\/mediawiki\/srv\//g' LocalSettings.php

echo 'error_reporting(E_ALL| E_STRICT);' >> LocalSettings.php
echo 'ini_set("display_errors", 1);' >> LocalSettings.php
echo '$wgShowExceptionDetails = true;' >> LocalSettings.php
echo '$wgShowDBErrorBacktrace = true;' >> LocalSettings.php
echo '$wgDevelopmentWarnings = true;' >> LocalSettings.php

tail -n5 LocalSettings.php

#php maintenance/sqlite.php extensions/CreateWiki/sql/cw_comments.sql
#php maintenance/sqlite.php extensions/CreateWiki/sql/cw_requests.sql
#php maintenance/sqlite.php extensions/CreateWiki/sql/cw_wikis.sql

mysql -h "127.0.0.1" --port 3306 -u "root" "mediawiki" < "extensions/CreateWiki/sql/cw_wikis.sql"
cd data
ls
#sqlite3 mediawiki.sqlite ".read /home/runner/work/mediawiki/mediawiki/srv/mediawiki/w/extensions/CreateWiki/sql/cw_wikis.sql"
cd ..

php maintenance/update.php
