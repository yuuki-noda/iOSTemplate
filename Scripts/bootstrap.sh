#!/bin/zsh

TEMPLATE_OPTIONS="./Genesis/Generated/BootstrapOptions.yml"
DEVELOPER_INFO="./Genesis/Generated/DeveloperInfo.yml"

Generate() {
    if [ $# -eq 1 ]; then
        if [ $1 = "force" ]; then
            echo "Remove BootstrapOptions.yml"
            rm -f $TEMPLATE_OPTIONS
        fi
    fi
    if [ ! -e $TEMPLATE_OPTIONS ]; then
        mint run genesis generate Genesis/template_project.yml
    else
        echo "Load BootstrapOptions.yml"
        mint run genesis generate Genesis/template_project.yml -p $TEMPLATE_OPTIONS
    fi

    echo -n "Do you want to setup API Key? [y/n]"
    read GENERATE_API_KEY
    case $GENERATE_API_KEY in
        "" | [Yy]*)
            mint run genesis generate Genesis/template_api_key.yml
        ;;
    *)
        ;;
    esac

    echo -n "Do you want to setup Slack for fastlane? [y/n]"
    read GENERATE_SLACK
    case $GENERATE_SLACK in
        "" | [Yy]*)
            mint run genesis generate Genesis/template_slack.yml
        ;;
    *)
        ;;
    esac
}

PrintError() {
    echo "DeveloperInfo.yml is already generated. Delete \"Genesis/Generated/DeveloperInfo.yml\" to regenerate. Pass 'regenerate' to skip this message."
}

if [ ! -e $DEVELOPER_INFO ]; then
    Generate
else
    if [ $# -eq 1 ]; then
        if [ $1 = "regenerate" ]; then
            echo "Regenerate files from template_project.yml"
            Generate
        else
            PrintError
        fi
    else
        PrintError
    fi
fi