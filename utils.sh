#!/usr/bin/env bash

# This function returns the filename of the calling script.
function _get_current_filename() {
	basename "${0}"
	if [[ $? -ne 0 ]]; then
		_perror "Failed to get the current filename!"
		exit 1
	fi
	return 0
}

# This function returns the runtime directory of the calling script.
function _get_runtime_dir() {
	local runtime_relative_path runtime_absolute_path
	runtime_relative_path="$(dirname "${0}")"
	if [[ $? -ne 0 ]]; then
		_perror "Failed to get the runtime directory relative path!"
		exit 1
	else
		runtime_absolute_path=$(_get_absolute_path "${runtime_relative_path}")
		if [[ $? -ne 0 ]]; then
			_perror "Failed to get the runtime directory absolute path!"
			exit 1
		else
			echo -n "${runtime_absolute_path}"
			return 0
		fi
	fi
}

# This function returns an absolute path from a given relative path.
# ${1} : String, the relative path to transform
# Usage: _get_absolute_path "../.."
function _get_absolute_path() {
	local cwd relative_path
	cwd=$(pwd)
	relative_path="${1}"
	cd "${relative_path}" || { _perror "Failed to change directory to the relative path: ${relative_path}" ; return 1 ; }
	echo -n "$(pwd)"
	cd "${cwd}" || { _perror "Failed to change back to the original working directory: ${cwd}" ; return 1 ; }
	return 0
}

# This function prints some environment variables.
# ${1} : String, the string to filter on
# Usage: _penvironment "ANT"
function _penvironment() {
	if [[ -z ${1+x} ]]; then
		env
	else
		for _key in "${@}"; do
			echo -e "${_key} variables:"
			env | grep "${_key}"
		done
	fi
	return 0
}

# This function prints an information message.
# ${1} : String, the message to print
# Usage: _pinfo "Hello world!"
function _pinfo() {
	echo -e "\e[34m[INFO] $(_pdate) ${1}\e[0m"
	return 0
}

# This function prints an error message.
# ${1} : String, the message to print
# Usage: _perror "Hello world!"
function _perror() {
	echo -e "\e[31m[ERROR] $(_pdate) ${1}\e[0m" >&2
	return 0
}

# This function prints a warning message.
# ${1} : String, the message to print
# Usage: _pwarning "Hello world!"
function _pwarning(){
	echo -e "\e[33m[WARNING] $(_pdate) ${1}\e[0m"
	return 0
}

# This function prints a success message.
# ${1} : String, the message to print
# Usage: _psuccess "Hello world!"
function _psuccess(){
	echo -e "\e[32m[SUCCESS] $(_pdate) ${1}\e[0m"
	return 0
}

# This function prints a debug message if the _verbose variable is set in the current shell.
# ${1} : String, the message to print
# Usage: _pdebug "Hello world!"
function _pdebug() {
	if [[ "${_verbose}" == true ]]; then
		echo -e "\e[35m[DEBUG] $(_pdate) [$(_get_current_filename):${FUNCNAME[1]}] ${1}\e[0m"
	fi
	return 0
}

# This function prints the current date in the hh:mm:ss format.
function _pdate() {
	echo -n "[$(date +%H:%M:%S)]"
	return 0
}

# This function is used to silence the given command if the _silent variable is set in the current shell.
# ${1} : String, the command to execute
# Usage: _silence "ls -al"
function _silence() {
	local mycommand="${*}"
	_pdebug "${mycommand}"
	if [[ "${_silent}" == true ]]; then
		${mycommand} >/dev/null
	else
		${mycommand}
	fi
	return ${?}
}

# This function is used to reset the builtin SECONDS variable of the shell to 0.
function _reset_timer() {
	SECONDS=0
	return 0
}

# This function is used to get the elapsed time base on the builtin SECONDS variable of the shell.
function _get_elapsed_time() {
	echo -n "$((SECONDS / 60))min $((SECONDS % 60))sec"
	return 0
}

# This function is used to check that the given parameter is an integer.
# ${1} : String/Integer, the value to verify
# Usage: _isinteger "aa"
function _isinteger() {
	isinteger_usage() { echo "isinteger <arg>" ; return 0; }
	local arg="${1}"
	if [[ $arg =~ ^-?[0-9]+$ ]] ; then return 0 ; else return 1 ; fi
}

# This function is used to check that the given key is in the given array.
# ${1} : String, the value to look for
# ${2} : Array, the values to look at
# Usage: array=(aa bb cc) && _isinarray "aa" ${array[@]}
function _isinarray() {
	local item it array
	isinarray_usage() { echo "isinarray <item> <array>" ; return 0; }
	item="${1}" ; shift ; array=("${@}")
	for it in "${!array[@]}"; do if [[ "${array[${it}]}" == "${item}" ]] ; then return 0 ; fi done
	return 1
}

# This function prints a menu lign.
# ${1} : String, the message to print in the lign. Default is empty.
# ${2} : String/Integer, the length of the lign to print. Default is 75.
# ${3} : String, the character used to print the lign. Default is "-".
# Usage: _menu_lign "OPTION" 75 "+"
function _menu_lign() {
	local line msg length sep msg_offset
	msg=${1}
	msg_offset=5
	length=${2:-75}
	sep=${3:--}
	# Should use printf -v var ; but Solaris of course
	line="$(printf "%*s" "${length}")" && echo -en "\e[34m${line// /${sep}}\e[0m"
	if [[ ! -z ${msg+x} ]]; then
		echo -e "\r\033[${msg_offset}C\e[1;34m${msg}\e[0m"
	fi
	return 0
}

# This function prints a message containing the script name and the usage keyword.
function _menu_header() {
	printf "\e[1;34mUsage: %s [OPTIONS]\e[0m\n" "${0##*/}"
	return 0
}

# This function prints a menu option.
# ${1} : String, the parameter name.
# ${2} : String, the parameter description.
# ${3} : String, the parameter authorized values.
# Usage: _menu_option "--hello" "The hello option." "{01234567}"
function _menu_option() {
	local padding sep option helper values
	padding="$(printf "%*s" 10)"
	sep=" : "
	option="${1}" ; helper="${2}" ; values="${3}"
	printf "${padding}\e[1m%-20s${sep}\e[0m%-50s\n" "${option}" "${helper}"
	if [[ ! -z ${values+x} && ${values} != "" ]]; then
		printf "${padding}%-$((20 + ${#sep}))sValues: \e[1m%-30s\e[0m\n" "" "${values}"
	fi
	return 0
}

# This function prints a table row.
# ${1} : String, the lign header (col0).
# ${2} : String, col1.
# Usage: _menu_table_row "Test:" "This is a test"
function _menu_table_row() {
	local header col1
	header="${1}" ; col1="${2}"
	printf "\e[1m%-10s:\e[0m %-30s\n" "${header}" "${col1}"
	return 0
}

# This function prints a menu footer.
function _menu_footer() {
	printf "\e[1;32m%s\e[0m\n" "Report bugs to @aallrd"
	return 0
}

# This function returns the current SunOS release and update with the format "release.update".
function _get_sunos_release() {
	local array release update
	if [[ "$(uname -r)" == "5.10" ]]; then
		array=($(ggrep -Eo '[0-9]{2}[[:space:]][0-9]{1,}/[0-9]{1,}' < /etc/release))
		release="${array[0]}"
		case "${array[1]}" in
			1/06) 	update="1" ;;
			6/06) 	update="2" ;;
			11/06) 	update="3" ;;
			8/07) 	update="4" ;;
			5/08) 	update="5" ;;
			10/08)	update="6" ;;
			5/09) 	update="7" ;;
			10/09) 	update="8" ;;
			9/10) 	update="9" ;;
			8/11) 	update="10" ;;
			1/13) 	update="11" ;;
			*) 		update="${array[1]}" ;;
		esac
	elif [[ "$(uname -r)" == "5.11" ]]; then
		array=($(ggrep -Eo '11\.[0-9]{1,}' < /etc/release | tr '.' ' '))
		release="${array[0]}"
		update="${array[1]}"
	else
		_perror "Unknown SunOS release: $(uname -r)"
		return 1
	fi
	echo -n "${release}.${update}"
	return 0
}

# This function returns the current Linux release and update with the format "release.update".
function _get_linux_release() {
	local array release update
	if command -v lsb_release >/dev/null ; then
		array=($(lsb_release -a | grep Release | awk '{print $2}' | tr '.' ' '))
	else
		array=($(grep -Eo '[0-9]{1}\.[0-9]{1}' < /etc/redhat-release | tr '.' ' '))
	fi
	release="${array[0]}"
	update="${array[1]}"
	echo -n "${release}.${update}"
	return 0
}

# This function returns the current Linux release and update with the format "release.update".
function _get_aix_release() {
	local release update
	release="$(uname -v)"
	update="$(uname -r)"
	echo -n "${release}.${update}"
	return 0
}

# This function returns the current platform architecture.
function _get_architecture() {
	if [[ "$(uname -p)" == "sparc" ]]; then
		echo -n "sparc"
	elif [[ "$(uname -p)" == "powerpc" ]]; then
		echo -n "ppc"
	else
		if [[ "$(uname)" == "Linux" ]]; then
			echo -n "i386"
		else
			echo -n "x86"
		fi
	fi
	return 0
}

# This function returns the current OS name.
function _get_local_os_name() {
	local os_name platform architecture release
	platform="$(uname)"
	architecture="$(_get_architecture)"
	if [[ "$(uname)" == "SunOS" ]]; then
		release="$(_get_sunos_release)"
	elif [[ "$(uname)" == "Linux" ]]; then
		release="$(_get_linux_release)"
	elif [[ "$(uname)" == "AIX" ]]; then
		release="$(_get_aix_release)"
	else
		_perror "The current platform is not supported: $(uname)"
		return 1
	fi
	os_name="${platform} ${release}"
	if [[ "$(uname)" == "SunOS" && "$(uname -p)" == "sparc" ]]; then
		os_name="${os_name} (sparc)"
	fi
	echo -n "${os_name}"
	return 0
}
