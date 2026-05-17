curl -L https://infostos.uek.krakow.pl/vhost.html -o /etc/apache2/sites-available/default-vhost.conf
cp /etc/apache2/sites-available/default-vhost.conf /etc/apache2/sites-available/default_vhost.conf

read -p "Podaj nazwe dla nowego uzytkownika: " nazwa_uzytkownika

if grep -qiw "$nazwa_uzytkownika" /etc/passwd
then
    echo "Blad: Uzytkownik o tej nazwie juz istnieje w systemie!"
    exit 1
fi

read -p "Podaj haslo dla nowego uzytkownika: " haslo

if [[ ${#haslo} -ge 8 && "$haslo" =~ [a-z] && "$haslo" =~ [A-Z] && "$haslo" =~ [0-9] ]]
then
    echo "Haslo spelnia wymagania."
else
    echo "Blad: Haslo musi miec minimum 8 znakow, jedna mala, jedna duza litere oraz cyfre!"
    exit 1
fi

useradd -m -d "/home/$nazwa_uzytkownika" -s /bin/bash "$nazwa_uzytkownika"
echo "$nazwa_uzytkownika:$haslo" | chpasswd

mkdir "/home/$nazwa_uzytkownika/apaczdwa"
chown "$nazwa_uzytkownika:$nazwa_uzytkownika" "/home/$nazwa_uzytkownika/apaczdwa"
chmod 777 "/home/$nazwa_uzytkownika/apaczdwa"
chmod 777 "/home/$nazwa_uzytkownika"

cp /etc/apache2/sites-available/default_vhost.conf "/etc/apache2/sites-available/$nazwa_uzytkownika.conf"

sed -i "s/vhost/$nazwa_uzytkownika/g" "/etc/apache2/sites-available/$nazwa_uzytkownika.conf"
sed -i "s/default_vhost/$nazwa_uzytkownika/g" "/etc/apache2/sites-available/$nazwa_uzytkownika.conf"

echo "127.0.0.1 $nazwa_uzytkownika.pl" >> /etc/hosts

a2ensite "$nazwa_uzytkownika.conf"
systemctl reload apache2

echo "test $nazwa_uzytkownika" > "/home/$nazwa_uzytkownika/apaczdwa/index.html"

echo "Sukces: Konfiguracja vhost zostala uruchomiona prawidlowo!"
