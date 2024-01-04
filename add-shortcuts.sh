#!/bin/bash

export ANDROID_HOME=${HOME}/Android/Sdk
export PATH=${PATH}:${ANDROID_HOME}/emulator
export PATH=${PATH}:${ANDROID_HOME}/platform-tools

# Diretório temporário local
temp_dir="$(pwd)/scripts_temp"

# Diretório de destino para os scripts
destination_dir="/usr/local/bin"

# Diretório para os arquivos .desktop
desktop_dir="$HOME/.local/share/applications"

# Diretório para o icone
icon_dir="$HOME/shortcuts-for-emulators"

# Crie o diretório temporário local se não existir
mkdir -p $temp_dir

# Crie o diretório .local/share/applications se não existir
mkdir -p $desktop_dir

# Crie o diretório $HOME/shortcuts-for-emulators se não existir
mkdir -p $icon_dir

cp "$(pwd)/smartphone.svg" "$HOME/shortcuts-for-emulators/smartphone.svg"

# Obtenha a lista de AVDs
avd_list=$(emulator -list-avds)

# Verifique se a lista não está vazia
if [ -n "$avd_list" ]; then
    for avd in $avd_list; do
        script_name="launch_emulator_${avd}"
        script_file="${temp_dir}/${script_name}"

        # Verifique se o script já existe antes de criar
        if [ ! -e "$script_file" ]; then
            echo "#!/bin/bash" >$script_file
            echo 'export ANDROID_HOME=${HOME}/Android/Sdk' >>$script_file
            echo 'export PATH=${PATH}:${ANDROID_HOME}/emulator' >>$script_file
            echo 'export PATH=${PATH}:${ANDROID_HOME}/platform-tools' >>$script_file
            echo "nohup emulator -avd ${avd} &" >>$script_file
            echo "sleep 5" >>$script_file
            echo "wmctrl -r ${avd} -b toggle,above" >>$script_file
            echo "Script $script_file criado e tornados executáveis com sucesso!"

            chmod +x $script_file
        else
            echo "Script $temp_script_file já existe. Pulando."
        fi

        # Crie o arquivo .desktop no diretório temporário
        desktop_file="${temp_dir}/launch_emulator_${avd}.desktop"
        echo "[Desktop Entry]" > $desktop_file
        echo "Version=1.0" >> $desktop_file
        echo "Type=Application" >> $desktop_file
        echo "Name=$avd" >> $desktop_file
        echo "Exec=$script_name" >> $desktop_file
        echo "Icon=$HOME/shortcuts-for-emulators/smartphone.svg" >> $desktop_file
        echo "Terminal=false" >> $desktop_file
        echo "Categories=Development;" >> $desktop_file
        chmod +x $desktop_file
        echo "Arquivo .desktop $desktop_file criado com sucesso!"
    done

    # Solicitar senha para mover os arquivos para os locais corretos
    sudo mv $temp_dir/*.desktop $desktop_dir
    sudo mv $temp_dir/* $destination_dir

    rm -r $temp_dir  # Remover diretório temporário
else
    echo "Nenhum AVD encontrado."
fi