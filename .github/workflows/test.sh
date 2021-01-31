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

sudo /etc/init.d/mysql start

mysql -u root -proot -e "CREATE DATABASE `mediawiki`;"
#mysql -u root -proot -e "CREATE DATABASE `mhglobal`;"
#mysql -u root -proot -e "CREATE DATABASE `metawiki`;"
#mysql -u root -proot -e "CREATE DATABASE `loginwiki`;"

php maintenance/install.php --dbtype=mysql --dbname=mediawiki --dbuser=root --dbpass=root --server=http://localhost --scriptpath=/w --pass=AdminPassword WikiName AdminUser

cd ..

mv w/LocalSettings.php config/PrivateSettings.php

mv config/LocalSettings.php w/LocalSettings.php
mv config/ManageWikiExtensions.php w/ManageWikiExtensions.php
mv config/ManageWikiNamespaces.php w/ManageWikiNamespaces.php
mv config/ManageWikiSettings.php w/ManageWikiSettings.php

cd config

echo -n "" > Database.php
echo -n "" > ExtensionMessageFiles.php

cd ..

cd w

echo  -n "INSERT INTO cw_wikis SET wiki_dbname = 'mediawiki', wiki_sitename = 'WikiName', wiki_language = 'en', wiki_private = 0, wiki_creation = 20150802185000, wiki_url = 'http://localhost', wiki_closed = 0, wiki_inactive = 0, wiki_inactive_exempt = 1, wiki_deleted = 0, wiki_locked = 0, wiki_dbcluster = 'c2', wiki_category = 'uncategorised', wiki_extensions = ''" > extensions/CreateWiki/sql/cw_wikis_insert.sql

sed -i -e 's/\/srv\//\/home\/runner\/work\/mediawiki\/mediawiki\/srv\//g' LocalSettings.php

sed -i -e "s/'mhglobal'/'mediawiki'/g" LocalSettings.php

sed -i -e "s/'metawiki'/'mediawiki'/g" LocalSettings.php

sed -i -e "s/'loginwiki'/'mediawiki'/g" LocalSettings.php

sed -i -e 's/https\:\/\/miraheze\.org/http\:\/\/localhost/g' LocalSettings.php

sed -i -e "s/'miraheze\.org'/'localhost'/g" LocalSettings.php

sed -i -e "s/\$_SERVER\['HTTP_HOST'\] \?\? 'undefined'/'localhost'/g" extensions/CreateWiki/includes/WikiInitialise.php

sed -i -e 's/https\:\/\//http\:\/\//g' extensions/CreateWiki/includes/WikiInitialise.php

sed -i -e "s/\. substr\( \$db, 0, \-strlen\( \$suffix \) \) \. '\.'//g" extensions/CreateWiki/includes/WikiInitialise.php

echo 'error_reporting(E_ALL| E_STRICT);' >> LocalSettings.php
echo 'ini_set("display_errors", 1);' >> LocalSettings.php
echo '$wgShowExceptionDetails = true;' >> LocalSettings.php
echo '$wgShowDBErrorBacktrace = true;' >> LocalSettings.php
echo '$wgDevelopmentWarnings = true;' >> LocalSettings.php

tail -n5 LocalSettings.php

mysql -u "root" -proot "mediawiki" < "extensions/CreateWiki/sql/cw_wikis.sql"

mysql -u "root" -proot "mediawiki" < "extensions/CreateWiki/sql/cw_wikis_insert.sql"


php maintenance/mergeMessageFileList.php --output=/home/runner/work/mediawiki/mediawiki/srv/mediawiki/config/ExtensionMessageFiles.php --wiki=mediawiki

php maintenance/rebuildLocalisationCache.php --wiki=mediawiki

php maintenance/update.php --wiki=mediawiki
