# ignore connected apps for package version creation since these can't be part of namespaced packages
echo "\n**/*.connectedApp-meta.xml" >> .forceignore 

case $(uname | tr '[:upper:]' '[:lower:]') in
  linux*)
    OS=linux
    ;;
  darwin*)
    OS=osx
    ;;
  msys*)
    OS=windows
    ;;
  *)
    OS=notset
    ;;
esac

default_skip_validation=0

# extract arguments
while [[ "$#" -gt 0 ]]
do
	case $1 in
		-p|--package)
			PACKAGE="$2"
			;;
		--skipvalidation)
			SKIP_VALIDATION="1"
			;;
	esac
	shift
done

skip_validation=${SKIP_VALIDATION:-$default_skip_validation}


if [ "$skip_validation" = "1" ]
then
	sfdx force:package:version:create -p "${PACKAGE}" --installationkeybypass --skipvalidation  -w 25
else
	sfdx force:package:version:create -p "${PACKAGE}" --installationkeybypass -w 25
fi

# whitelist connected apps from .forceignore after command runs

if [[ $OS == 'linux' ]]; then
   sed '$d' .forceignore
elif [[ $OS == 'osx' ]]; then
   sed -i '' -e '$ d' .forceignore
fi
