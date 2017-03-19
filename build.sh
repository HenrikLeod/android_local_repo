#!/bin/bash
# TeamVee, Henrikleod
# não vou traduzir os comentarios, ate porque não é necessario
# variaveis genericas
_android="6.0.1"
_android_version="MarshMallow"
_custom_android="cm-13.0"
_custom_android_version="CyanogenMod13.0"
_github_custom_android_place="CyanogenMod"
_github_device_place="TeamVee"


while true
do
	_unset_and_stop() {
		unset _device _device_build _device_echo
		break
	}

	_if_fail_break() {
		${1}
		if ! [ "${?}" == "0" ]
		then
			echo "  |"
			echo "  | Erro desconhecido!"
			echo "  | Fechando script!"
			_unset_and_stop
		fi
	}

	# Unset devices variables for not have any problem
	unset _device _device_build _device_echo

	# Check if is using 'BASH'
	if [ ! "${BASH_VERSION}" ]
	then
		echo "  |"
		echo "  | Por favor, não use 'sh' para rodar esse script"
		echo "  | Use o comando 'source build.sh'"
		echo "  | Fechando script!"
		_unset_and_stop
	fi

	# Check if 'repo' is installed
	if [ ! "$(which repo)" ]
	then
		echo "  |"
		echo "  | Voce precisa instalar o binário 'repo'"
		echo "  | Ele está disponivel neste link:"
		echo "  | <https://source.android.com/source/downloading.html>"
		echo "  | Fechando script!"
		_unset_and_stop
	fi

	# Check if 'curl' is installed
	if [ ! "$(which curl)" ]
	then
		echo "  |"
		echo "  | Voce precisa instalar o binário 'curl'"
		echo "  | Use 'sudo apt-get install curl' para instalar"
		echo "  | Fechando script!"
		_unset_and_stop
	fi

	# Name of script
	echo "  |"
	echo "  | Script de sincronização e compilação do Android"
	echo "  | Para Android ${_android_version} (${_android}) | ${_custom_android_version} (${_custom_android})"

	# Check option of user and transform to script
	for _u2t in "${@}"
	do
		if [[ "${_u2t}" == "-h" || "${_u2t}" == "--help" ]]
		then
			echo "  |"
			echo "  | Use:"
			echo "  | -h    | --help  | Para exibir esta mensagem"
			echo "  |"
			echo "  | -l5   | --e610  | Para compilar apenas para o L5/e610"
			echo "  | -l7   | --p700  | Para compilar apenas para o L7/p700"
			echo "  | -gen1 | --gen1  | Para compilar para o L5 and L7"
			echo "  |"
			echo "  | -l1ii | --v1    | Para compilar apenas para o L1II/v1"
			echo "  | -l3ii | --vee3  | Para compilar apenas para o L3II/vee3"
			echo "  | -gen2 | --gen2  | Para compilar para o L1II and L3II"
			_option_exit="enable"
			_unset_and_stop
		fi
		# Choose device before menu
		if [[ "${_u2t}" == "-l5" || "${_u2t}" == "--e610" ]]
		then
			_device="gen1"
			_device_build="e610"
			_device_echo="L5"
		fi
		if [[ "${_u2t}" == "-l7" || "${_u2t}" == "--p700" ]]
		then
			_device="gen1"
			_device_build="p700"
			_device_echo="L7"
		fi
		if [[ "${_u2t}" == "-gen1" || "${_u2t}" == "--gen1" ]]
		then
			_device="gen1"
			_device_build="gen1"
			_device_echo="All Gen1"
		fi
		if [[ "${_u2t}" == "-l1ii" || "${_u2t}" == "--v1" ]]
		then
			_device="gen2"
			_device_build="v1"
			_device_echo="L1II"
		fi
		if [[ "${_u2t}" == "-l3ii" || "${_u2t}" == "--vee3" ]]
		then
			_device="gen2"
			_device_build="vee3"
			_device_echo="L3II"
		fi
		if [[ "${_u2t}" == "-gen2" || "${_u2t}" == "--gen2" ]]
		then
			_device="gen2"
			_device_build="gen2"
			_device_echo="All Gen2"
		fi
	done

	# Exit if option is 'help'
	if [ "${_option_exit}" == "enable" ]
	then
		unset _option_exit
		_unset_and_stop
	fi

	# Repo Sync
	echo "  |"
	echo "  | Iniciando a sincronização do Android Tree Manifest"

	# Device Choice
	echo "  |"
	echo "  | Escolha o Manifest para download:"
	echo "  | 1 | Primeira geração | LG Optimus L5/L7 (NoNFC)"
	echo "  | 2 | Segunda geração  | LG Optimus L3II/L1II"
	echo "  |"
	if [ "${_device}" == "" ]
	then
		read -p "  | Digite | 1/ 2/ ou qualquer outra tecla pra sair | " -n 1 -s x
		case "${x}" in
			1) _device="gen1";;
			2) _device="gen2";;
			*) echo "${x} | Fechando script!"; _unset_and_stop;;
		esac
	fi
	echo "  | Usando ${_device}_manifest.xml"

	# Remove old Manifest of Android Tree
	echo "  |"
	echo "  | Removendo Manifests antigos para poder baixar um novo"
	rm -rf .repo/manifests .repo/manifests.git .repo/manifest.xml .repo/local_manifests/

	# Initialization of Android Tree
	echo "  |"
	echo "  | Baixando Android Tree Manifest de ${_github_custom_android_place} (${_custom_android})"
	_if_fail_break "repo init -u git://github.com/${_github_custom_android_place}/android.git -b ${_custom_android} -g all,-notdefault,-darwin"

	# Device manifest download
	echo "  |"
	echo "  | Baixando ${_device}_manifest.xml e msm7x27a_manifest.xml"
	echo "  | From ${_github_device_place} (${_custom_android})"
	_if_fail_break "curl -# --create-dirs -L -o .repo/local_manifests/${_device}_manifest.xml -O -L https://raw.github.com/${_github_device_place}/android_.repo_local_manifests/${_custom_android}/${_device}_manifest.xml"
	_if_fail_break "curl -# --create-dirs -L -o .repo/local_manifests/msm7x27a_manifest.xml -O -L https://raw.github.com/${_github_device_place}/android_.repo_local_manifests/${_custom_android}/msm7x27a_manifest.xml"

	# Initialize environment
	echo "  |"
	echo "  | Iniciando o ambiente"
	_if_fail_break "source build/envsetup.sh"

	# Real 'repo sync'
	echo "  |"
	echo "  | Iniciando sincronização:"
	_if_fail_break "reposync -q --force-sync"

	# Initialize environment
	echo "  |"
	echo "  | Iniciando o ambiente"
	_if_fail_break "source build/envsetup.sh"

	# Another device choice
	echo "  |"
	echo "  | Para qual dispositivo voce quer compilar?:"
	echo "  |"
	if [ "${_device}" == "gen1" ]
	then
		echo "  | 1 | LG Optimus L5 NoNFC | E610 E612 E617"
		echo "  | 2 | LG Optimus L7 NoNFC | P700 P705"
		echo "  | 3 | Todos os dispositivos acima"
		echo "  |"
		if [ "${_device_build}" == "" ]
		then
			read -p "  | Digite | 1/2/3/ ou * para sair | " -n 1 -s x
			case "${x}" in
				1) _device_build="e610" _device_echo="L5";;
				2) _device_build="p700" _device_echo="L7";;
				3) _device_build="gen1" _device_echo="All Gen1";;
				*) echo "${x} | Fechando script!"; _unset_and_stop;;
			esac
		fi
	elif [ "${_device}" == "gen2" ]
	then
		echo "  | 1 | LG Optimus L1II Single Dual | E410 E411 E415 E420"
		echo "  | 2 | LG Optimus L3II Single Dual | E425 E430 E431 E435"
		echo "  | 3 | Todos os dispositivos acima"
		echo "  |"
		if [ "${_device_build}" == "" ]
		then
			read -p "  | Digite | 1/2/3/ ou * para sair| " -n 1 -s x
			case "${x}" in
				1) _device_build="v1" _device_echo="L1II";;
				2) _device_build="vee3" _device_echo="L3II";;
				3) _device_build="gen2" _device_echo="All Gen2";;
				*) echo "${x} | Fechando script!"; _unset_and_stop;;
			esac
		fi
	fi
	echo "  | Compilando para o ${_device_echo}"
	# Builing Android
	echo "  |"
	echo "  | Iniciando compilação!"
	if [[ "${_device_build}" == "e610" || "${_device_build}" == "gen1" ]]
	then
		_if_fail_break "brunch e610"
	fi
	if [[ "${_device_build}" == "p700" || "${_device_build}" == "gen1" ]]
	then
		_if_fail_break "brunch p700"
	fi
	if [[ "${_device_build}" == "v1" || "${_device_build}" == "gen2" ]]
	then
		_if_fail_break "TARGET_KERNEL_V1_BUILD_DEVICE=true brunch vee3"
	fi
	if [[ "${_device_build}" == "vee3" || "${_device_build}" == "gen2" ]]
	then
		_if_fail_break "TARGET_KERNEL_V1_BUILD_DEVICE=false brunch vee3"
	fi

	# Exit
	_unset_and_stop
done

# Goodbye!
echo "  |"
echo "  | Obrigado por usar este script!"
