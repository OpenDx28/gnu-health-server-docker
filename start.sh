# "postgres" below is the name of the container running PostgreSQL
# Execute gnuhealth account profile scripts: .profile and .bashrc
. /home/gnuhealth/.profile
. /home/gnuhealth/.bashrc
. /home/gnuhealth/.gnuhealthrc
#createdb -h ${DB_HOST} -U gnuhealth -w gnuhealth
createdb -h ${DB_HOST} -U gnuhealth -w ${DB_NAME}
#cdexe
cd /home/gnuhealth/gnuhealth/tryton/server/trytond-6.0.30/bin
#-c /home/gnuhealth/trytond.conf
sed -i "s|^DB_URI.*|uri = postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:5432/|" /home/gnuhealth/gnuhealth/tryton/server/config/trytond.conf
#python3 ./trytond-admin --all --database=gnuhealth
python3 ./trytond-admin --all --database=${DB_NAME}
cd /home/gnuhealth
./start_gnuhealth.sh
