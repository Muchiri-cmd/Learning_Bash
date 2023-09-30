os=Fedora

case $os in
  "Fedora") echo "Uses RPM package manager" ;;

  "RHEL") echo "Uses RPM package manager";;

  "CentOS") echo "Uses RPM package manager";;

  "Debian") echo "Uses DEB package manager" ;;

  "Ubuntu")
            echo "Uses DEB package manager" ;;
esac
