#!/bin/bash
echo "========================================================================================="
echo -e "\033[0;35m"
echo -e "KKKKKKKKK    KKKKKKK               CCCCCCCCCCCCC         DDDDDDDDDDDDD"        
echo -e "K:::::::K    K:::::K            CCC::::::::::::C         D::::::::::::DDD"     
echo -e "K:::::::K    K:::::K          CC:::::::::::::::C         D:::::::::::::::DD"   
echo -e "K:::::::K   K::::::K         C:::::CCCCCCCC::::C         DDD:::::DDDDD:::::D"  
echo -e "KK::::::K  K:::::KKK        C:::::C       CCCCCC           D:::::D    D:::::D" 
echo -e "  K:::::K K:::::K          C:::::C                         D:::::D     D:::::D"
echo -e "  K::::::K:::::K           C:::::C                         D:::::D     D:::::D"
echo -e "  K:::::::::::K            C:::::C                         D:::::D     D:::::D"
echo -e "  K:::::::::::K            C:::::C                         D:::::D     D:::::D"
echo -e "  K::::::K:::::K           C:::::C                         D:::::D     D:::::D"
echo -e "  K:::::K K:::::K          C:::::C                         D:::::D     D:::::D"
echo -e "KK::::::K  K:::::KKK        C:::::C       CCCCCC           D:::::D    D:::::D" 
echo -e "K:::::::K   K::::::K         C:::::CCCCCCCC::::C         DDD:::::DDDDD:::::D"  
echo -e "K:::::::K    K:::::K          CC:::::::::::::::C         D:::::::::::::::DD"   
echo -e "K:::::::K    K:::::K            CCC::::::::::::C         D::::::::::::DDD"     
echo -e "KKKKKKKKK    KKKKKKK               CCCCCCCCCCCCC         DDDDDDDDDDDDD"  
echo -e "\e[0m"
echo "========================================================================================="
sleep 2
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi


cd $HOME
rm -rf subspace*
wget -O subspace-node https://github.com/subspace/subspace/releases/download/gemini-1a-2022-may-31/subspace-node-ubuntu-x86_64-gemini-1a-2022-may-31
wget -O subspace-farmer https://github.com/subspace/subspace/releases/download/gemini-1a-2022-may-31/subspace-farmer-ubuntu-x86_64-gemini-1a-2022-may-31
chmod +x subspace*
mv subspace* /usr/local/bin/

systemctl stop subspaced subspaced-farmer &>/dev/null
rm -rf ~/.local/share/subspace*

source ~/.bash_profile
sleep 1

echo "[Unit]
Description=Subspace Node
After=network.target
[Service]
User=$USER
Type=simple
ExecStart=$(which subspace-node) --chain gemini-1 --execution wasm --pruning 1024 --keep-blocks 1024 --validator --name $SUBSPACE_NODENAME
Restart=on-failure
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target" > $HOME/subspaced.service


echo "[Unit]
Description=Subspaced Farm
After=network.target
[Service]
User=$USER
Type=simple
ExecStart=$(which subspace-farmer) farm --reward-address $SUBSPACE_WALLET --plot-size 40G
Restart=on-failure
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target" > $HOME/subspaced-farmer.service


mv $HOME/subspaced* /etc/systemd/system/
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced subspaced-farmer
sudo systemctl restart subspaced
sleep 10
sudo systemctl restart subspaced-farmer
echo '=============== УСТАНОВКА ЗАВЕРШЕНА ==================='
echo -e 'Проверка логов ноды: \e[1m\e[32mjournalctl -u subspaced -f -o cat \e[0m'
echo -e 'Проверка логов фармера: \e[1m\e[32mdocker logs subspace-farmer-1 \e[0m'
