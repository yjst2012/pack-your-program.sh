#!/bin/bash
function mkpackage(){
    target_dir="bin"
    fellow_install_shell_command_file=$1
    tar -zcf ._test_dir.tar.gz $target_dir
    base64 ._test_dir.tar.gz >._base64
    rm ._test_dir.tar.gz
    printf "test_base64=\"">setup.sh
    while IFS='' read -r line || [[ -n "$line" ]]; do
    printf "$line\\" >>setup.sh
    printf "n" >>setup.sh
    done <./._base64
    rm ._base64
    echo "\"" >>setup.sh
    echo 'if [[ $# == 0 ]]' >>setup.sh
    echo 'then' >>setup.sh
    echo 'echo "usage: "' >>setup.sh
    echo 'echo "    setup.sh command "' >>setup.sh
    echo 'echo "commands: "' >>setup.sh
    echo 'echo "    install              install  binaries onto this node"' >>setup.sh
    echo 'echo "    reinstall            reinstall binaries onto this node"' >>setup.sh
    echo 'echo "    update               update latest binaries from gitlab"' >>setup.sh
    echo 'echo "    version              show the version"' >>setup.sh
    echo 'exit' >>setup.sh
    echo 'fi' >>setup.sh
    echo 'if [[ $1 == update ]]' >>setup.sh
    echo 'then' >>setup.sh
    echo 'echo "fetching latest binaries..."' >>setup.sh
    echo 'curl -JL --header "PRIVATE-TOKEN: xxxxx" https://git.yourcompany.net/api/v4/projects/12/jobs/artifacts/staging/raw/linux_x86_64/setup.sh?job=build > _setup.sh' >>setup.sh
    echo 'filesize=`cat ./_setup.sh | wc -c`' >>setup.sh
    echo 'if [[ $filesize -lt $((9*1024*1024)) ]]' >>setup.sh
    echo 'then' >>setup.sh
    echo 'echo "the _setup.sh downloaded is incorrect, pls check your connection and try again!"' >>setup.sh
    echo 'exit' >>setup.sh
    echo 'fi' >>setup.sh
    echo 'chmod +x _setup.sh' >>setup.sh
    echo 'rm ./setup.sh' >>setup.sh
    echo 'mv ./_setup.sh ./setup.sh' >>setup.sh
    echo './setup.sh reinstall' >>setup.sh
    echo 'exit' >>setup.sh
    echo 'fi' >>setup.sh
    echo 'echo "extracting binaries..."' >>setup.sh
    echo 'printf $test_base64|base64 -d >._temp.tar.gz;'>>setup.sh
    echo 'tar zxf ._temp.tar.gz' >> setup.sh
    echo 'rm ._temp.tar.gz' >>setup.sh
    echo 'if [[ $1 == version ]]' >>setup.sh
    echo 'then' >>setup.sh
    echo './'$target_dir'/programctl -v' >>setup.sh
    echo 'fi' >>setup.sh
    echo 'if [[ $1 == install ]]' >>setup.sh
    echo 'then' >>setup.sh
    echo 'apt-get update' >>setup.sh
    echo 'curl -sSL https://get.docker.com/ | sh' >>setup.sh
    echo 'apt-get --yes install btrfs-tools zstd liblz4-tool iptables' >>setup.sh
    echo './'$target_dir'/programctl node new' >>setup.sh
    echo './'$target_dir'/programd --install' >>setup.sh
    echo 'fi' >>setup.sh
    echo 'if [[ $1 == reinstall ]]' >>setup.sh
    echo 'then' >>setup.sh
    echo 'echo "reinstalling"' >>setup.sh
    echo 'systemctl stop programd' >>setup.sh
    echo './'$target_dir'/programd --install' >>setup.sh
    echo 'fi' >>setup.sh
    echo 'rm -f ./bin/program*' >>setup.sh
    echo 'rmdir ./bin' >>setup.sh
    if [[ -e $fellow_install_shell_command_file ]]; then
        cat $fellow_install_shell_command_file >>setup.sh
    fi
    chmod +x setup.sh
}
function usage(){
   echo "usage:"
   echo "    $1 [the_command.sh]"
}
if [[ $# < 2 ]]
then
    mkpackage $1
else
   usage $0
fi
