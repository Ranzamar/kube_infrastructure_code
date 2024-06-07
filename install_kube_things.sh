gcloud config set compute/zone us-west1-a 
for vm in $(gcloud compute instances list --format='value(name)')
do
  echo "Copia script su $vm in corso"
  gcloud compute scp ./scriptafterdeploy.sh $vm:/tmp/
  gcloud compute ssh $vm --command="sudo chmod 777 /tmp/scriptafterdeploy.sh; sudo /tmp/scriptafterdeploy.sh;"
done
