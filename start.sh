# "postgres" below is the name of the container running PostgreSQL
# Execute gnuhealth account profile scripts
shopt -s expand_aliases
. /home/gnuhealth/.profile
. /home/gnuhealth/.bashrc
. /home/gnuhealth/.gnuhealthrc

cd ~
chmod u+x set_admin_password.exp

createdb -h ${DB_HOST} -U gnuhealth -w ${DB_NAME}
cdexe
export EXE_PATH=`pwd`
sed -i "s|^DB_URI.*|uri = postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:5432/|" /home/gnuhealth/gnuhealth/tryton/server/config/trytond.conf
python3 ./trytond-admin --all --database=${DB_NAME}
# The first time, modify the admin password using expect
INIT_FILE="/home/gnuhealth/container_initialized"
if [ ! -f "$INIT_FILE" ]; then
    echo "First-time container initialization..."
    /home/gnuhealth/set_admin_password.exp
    touch "$INIT_FILE"
    echo "Container initialized."
else
    echo "Container already initialized."
fi

cd /home/gnuhealth
./start_gnuhealth.sh
