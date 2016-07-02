#! /bin/sh
#
# parse a yaml file and turn it into an approx config
#

set -e

# function to turn yaml into variables
parse_yaml()
{
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_-]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   gawk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# get the piped input and store it in a tmpfile
while IFS= read -r LINE; do
    if [ ! "$(id -u)" = "0" ]; then
        echo -n "permission denied (try sudo)"
        exit 1
    fi
    printf "%s\n" "$LINE" >>$SNAP_DATA/.tmp.yaml
done

# if we have permissions, write the different configs
if [ "$(id -u)" = "0" ]; then

    # get all the vars from yaml
    eval $(parse_yaml $SNAP_DATA/config.yaml)
    if [ -e "$SNAP_DATA/.tmp.yaml" ]; then
        eval $(parse_yaml $SNAP_DATA/.tmp.yaml)
    fi

    # put a new config.yaml in place
    cat << EOF >$SNAP_DATA/config.yaml
config:
  packageproxy:
    repos: $config_packageproxy_repos
    interval: $config_packageproxy_interval
    max_rate: $config_packageproxy_max_rate
    max_redirects: $config_packageproxy_max_redirects
    pdiffs: $config_packageproxy_pdiffs
    offline: $config_packageproxy_offline
    max_wait: $config_packageproxy_max_wait
    verbose: $config_packageproxy_verbose
    debug: $config_packageproxy_debug
    port: $config_packageproxy_port
EOF


    # create the actual approx configuration
    >$SNAP_DATA/approx.conf
    if [ ! "$config_packageproxy_repos" = "[]" ]; then
        echo "$config_packageproxy_repos" | \
          sed "s/\][ ]*,[ ]*\[/\\n/g;s/\(\]\)//g;s/\(\[\)//g;s/\x27//g;s/,/\t/g" \
          >>$SNAP_DATA/approx.conf
    else
        echo "ubuntu http://archive.ubuntu.com/ubuntu" \
          >>$SNAP_DATA/approx.conf
    fi
    cat << EOF >>$SNAP_DATA/approx.conf

\$cache $SNAP_DATA/var/cache/approx
\$interval $config_packageproxy_interval
\$max_rate $config_packageproxy_max_rate
\$max_redirects $config_packageproxy_max_redirects
\$user root
\$group root
\$pdiffs $config_packageproxy_pdiffs
\$offline $config_packageproxy_offline
\$max_wait $config_packageproxy_max_wait
\$verbose $config_packageproxy_verbose
\$debug $config_packageproxy_debug
EOF

    chmod 0640 $SNAP_DATA/approx.conf

    # flush the tmpfile
    >$SNAP_DATA/.tmp.yaml
fi

cat $SNAP_DATA/config.yaml
