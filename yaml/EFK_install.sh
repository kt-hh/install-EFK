# Create namespace & insert version info

export ES_VERSION=7.2.0
export KIBANA_VERSION=7.2.0
export FLUENTD_VERSION=v1.4.2-debian-elasticsearch-1.1
export BUSYBOX_VERSION=1.32.0
if [ -z $1 ]; then
  export STORAGECLASS_NAME=
  echo "STORAGECLASS_NAME = Default-StorageClass"
else
  export STORAGECLASS_NAME=$1
  echo "STORAGECLASS_NAME = $STORAGECLASS_NAME"
fi

echo "ES_VERSION = $ES_VERSION"
echo "KIBANA_VERSION = $KIBANA_VERSION"
echo "FLUENTD_VERSION = $FLUENTD_VERSION"
echo "BUSYBOX_VERSION = $BUSYBOX_VERSION"

sed -i 's/{busybox_version}/'${BUSYBOX_VERSION}'/g' 01_elasticsearch.yaml
sed -i 's/{es_version}/'${ES_VERSION}'/g' 01_elasticsearch.yaml
sed -i 's/{storageclass_name}/'${STORAGECLASS_NAME}'/g' 01_elasticsearch.yaml
sed -i 's/{kibana_version}/'${KIBANA_VERSION}'/g' 02_kibana.yaml
sed -i 's/{fluentd_version}/'${FLUENTD_VERSION}'/g' 03_fluentd.yaml
sed -i 's/{fluentd_version}/'${FLUENTD_VERSION}'/g' 03_fluentd_cri-o.yaml

# Install EFK
echo "---Installation Start---"
kubectl create ns kube-logging

kubectl apply -f 01_elasticsearch.yaml
timeout 5m kubectl -n kube-logging wait --for=condition=ready pod -l app=elasticsearch
suc=`echo $?`
if [ $suc != 0 ]; then
  echo "Failed to install ElasticSearch"
  exit 1
else
  echo "elasticsearch running success" 
  sleep 1m
fi

kubectl apply -f 02_kibana.yaml
kubectl apply -f 03_fluentd_cri-o.yaml  
echo "---Installation Done---"
