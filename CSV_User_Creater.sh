#!/bin/bash

# Test mode: Display commands to create accounts
#./CSV_User_Creater.sh users.csv Count=1 Name=2 Password=3 Project=4 Email=5

# Execution mode: Create accounts
#./CSV_User_Creater.sh users.csv Count=1 Name=2 Password=3 Project=4 Work=

# Delete accounts
#./CSV_User_Creater.sh users.csv Count=1 Name=2 Password=3 Project=4 Delete=

# This script is designed to create multiple accounts in OpenStack from a CSV file.
# It processes command-line options to determine how to read the CSV file and execute
# OpenStack commands accordingly.

# Initialize variables
count_ok=0
name_ok=0
password_ok=0
project_ok=0
email_ok=0
description_ok=0

count_p=0
name_p=0
password_p=0
project_p=0
email_p=0
description_p=0

name_prefix=""
execute_commands=0
delete_accounts=0

# Display help message if 'h-' is provided as the first argument
if [ "$1" == "h-" ]; then
    echo "--------------------------------------------[Description]----------------------------------------------"
    echo "This program is designed to create multiple accounts in OpenStack from a CSV file."
    echo ""
    echo "---------------------------------------[Usage]------------------------------------------"
    echo "$0 [CSV file name] [options]..."
    echo ""
    echo "------------------------------------[Options and Usage]---------------------------------------"
    echo " Help=               : Displays program description and usage instructions"
    echo " Count=[number]      : Sets the [number]-th field in the CSV file as the count (fields ordered from 1 to n) {Required}"
    echo " Name=[number]       : Sets the [number]-th field in the CSV file as the account name                      {Required}"
    echo " Password=[number]   : Sets the [number]-th field in the CSV file as the account password                  {Required}"
    echo " Project=[number]    : Sets the [number]-th field in the CSV file as the account project name              {Optional}"
    echo " ProjectStr=[string] : Sets [string] as the account project name                                           {Optional}"
    echo " Email=[number]      : Sets the [number]-th field in the CSV file as the email                             {Optional}"
    echo " Description=[number]: Sets the [number]-th field in the CSV file as the description                       {Optional}"
    echo " NameAdd=[string]    : Adds [string] in front of the account name                                          {Optional}"
    echo " Work=               : Executes the commands instead of displaying them                                    {Optional}"
    echo " Delete=             : Deletes the specified accounts instead of creating them                             {Optional}"
    echo ""
    echo "------------------------------------------------------------------------------------------------"
    exit 0
fi

# Function to process and assign field numbers based on received command options
SetOption() {
    opt="${SO%%=*}"
    value="${SO#*=}"
    if [ "$opt" == "$value" ]; then
        value=""
    fi

    case "$opt" in
        "Name") # Position of Name
            name_p="$value"
            [ -z "$name_p" ] && name_p=0
            name_ok=$((name_ok + 1))
            ;;
        "Password") # Position of Password
            password_p="$value"
            [ -z "$password_p" ] && password_p=0
            password_ok=$((password_ok + 1))
            ;;
        "Count") # Position of Count
            count_p="$value"
            [ -z "$count_p" ] && count_p=0
            count_ok=$((count_ok + 1))
            ;;
        "Project") # Position of Project
            project_p="$value"
            [ -z "$project_p" ] && project_p=0
            project_ok=$((project_ok + 1))
            ;;
        "ProjectStr") # Project name as string
            project="$value"
            project_ok=$((project_ok + 1))
            ;;
        "Email") # Position of Email
            email_p="$value"
            [ -z "$email_p" ] && email_p=0
            email_ok=$((email_ok + 1))
            ;;
        "Description") # Position of Description
            description_p="$value"
            [ -z "$description_p" ] && description_p=0
            description_ok=$((description_ok + 1))
            ;;
        "NameAdd") # Prefix to add to account name
            name_prefix="$value"
            ;;
        "Work") # Execute commands
            execute_commands=1
            ;;
        "Delete") # Delete accounts
            delete_accounts=1
            ;;
        *)
            # If an unrecognized command is received, display an error and exit
            echo "------------------------------------------------------------------------------"
            echo "Unrecognized command: $SO"
            echo "------------------------------------------------------------------------------"
            exit 1
            ;;
    esac
}

# Main
# Process command-line options starting from the second argument
if [ $# -lt 1 ]; then
    echo "Error: CSV file name is required."
    exit 1
fi
csv_file="$1"
shift # Skip the first argument (CSV file name)

for SO in "$@"; do
    SetOption
done

# Verify that required options have been input correctly
if [ "$name_ok" -ne 1 ] || [ "$password_ok" -ne 1 ] || [ "$count_ok" -ne 1 ]; then
    echo "--------------------[Incorrect command input.]-----------------------"
    echo "Options 'Name', 'Password', and 'Count' are required."
    echo "Options may have been duplicated or missing."
    echo "-----------------------------------------------------------------------------"
    echo "File name: $csv_file"
    echo "Number of times options were input:"
    echo "Name       = $name_ok"
    echo "Password   = $password_ok"
    echo "Count      = $count_ok"
    echo "Project    = $project_ok"
    echo "-----------------------------------------------------------------------------"
    exit 1
fi

# Ensure that project option is specified only once
if [ "$project_ok" -eq 0 ]; then
    echo "--------------------[Incorrect command input.]-----------------------"
    echo "Option 'Project' or 'ProjectStr' is required."
    echo "-----------------------------------------------------------------------------"
    exit 1
elif [ "$project_ok" -ge 2 ]; then
    echo "--------------------[Incorrect command input.]-----------------------"
    echo "Project option is duplicated."
    echo "-----------------------------------------------------------------------------"
    exit 1
fi

# Verify that the CSV file exists
if [ ! -f "$csv_file" ]; then
    echo "Error: CSV file '$csv_file' not found."
    exit 1
fi

# Verify that the file information is correct; if there is a problem, display an error message and exit
count_c=0
name_c=0
password_c=0
project_c=0
count=1
while IFS=',' read -r -a fields; do
    count_r="${fields[$((count_p - 1))]}"
    if [ "$count_r" == "$count" ]; then
        name="${fields[$((name_p - 1))]}"
        [ -n "$name" ] && name_c=$((name_c + 1))
        password="${fields[$((password_p - 1))]}"
        [ -n "$password" ] && password_c=$((password_c + 1))
        if [ "$project_p" -ne 0 ]; then
            project="${fields[$((project_p - 1))]}"
            [ -n "$project" ] && project_c=$((project_c + 1))
        fi
        count=$((count + 1))
        count_c=$((count_c + 1))
    fi
done < "$csv_file"

# If unreadable information is found, display an error message and exit
if [ "$count_c" -ne "$name_c" ] || [ "$count_c" -ne "$password_c" ] || ([ "$project_p" -ne 0 ] && [ "$count_c" -ne "$project_c" ]); then
    echo "----------------------------------------------------------------------"
    echo "There is information in '$csv_file' that cannot be read."
    echo "Number of entries read: $count_c"
    echo "Name entries     = $name_c"
    echo "Password entries = $password_c"
    echo "Project entries  = $project_c"
    echo "----------------------------------------------------------------------"
    exit 1
fi

# Read the file and create or delete accounts
count=1
created_count=0
while IFS=',' read -r -a fields; do
    count_r="${fields[$((count_p - 1))]}"
    if [ "$count_r" == "$count" ]; then
        name="${fields[$((name_p - 1))]}"
        password="${fields[$((password_p - 1))]}"
        if [ "$project_p" -ne 0 ]; then
            project="${fields[$((project_p - 1))]}"
        fi
        if [ "$email_p" -ne 0 ]; then
            email="${fields[$((email_p - 1))]}"
        fi
        if [ "$description_p" -ne 0 ]; then
            description="${fields[$((description_p - 1))]}"
        fi
        # Account creation or deletion
        if [ -z "$project" ]; then
            echo "Error: Project must be specified for each account."
            break
        else
            full_name="$name_prefix$name"
            if [ $execute_commands -eq 0 ]; then
                # Display commands
                if [ $delete_accounts -eq 0 ]; then
                    # Create account commands
                    if [ $email_ok -eq 1 ]; then
                        echo "openstack user create --domain default --project '$project' --email '$email' --password '$password' '$full_name'"
                    else
                        echo "openstack user create --domain default --project '$project' --password '$password' '$full_name'"
                    fi
                    echo "openstack role add --project '$project' --user '$full_name' --user-domain default member"
                else
                    # Delete account command
                    echo "openstack user delete --domain default '$full_name'"
                fi
            else
                # Execute commands
                if [ $delete_accounts -eq 0 ]; then
                    # Create account
                    if [ $email_ok -eq 1 ]; then
                        openstack user create --domain default --project "$project" --email "$email" --description "$description" --password "$password" "$full_name"
                    else
                        openstack user create --domain default --project "$project" --description "$description" --password "$password" "$full_name"
                    fi
                    openstack role add --project "$project" --user "$full_name" --user-domain default member
                else
                    # Delete account
                    openstack user delete --domain default "$full_name"
                fi
            fi
            created_count=$((created_count + 1))
        fi
        count=$((count + 1))
    fi
done < "$csv_file"

echo "Number of accounts processed: $created_count"

exit 0
