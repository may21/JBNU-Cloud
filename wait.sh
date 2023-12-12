echo "$(date +%m-%d-%H-%M-%S)"
while true; do
	#echo "1"
	string="$(openstack image list --status queued)"
	#echo "$string"
	if [[ -z "$string" ]]; then
		echo "$(date +%m-%d-%H-%M-%S)"
		echo "DONE!! Do next Job"
  		exit
	elif [[ -n "$string" ]]; then
	  	sleep 1
	fi
done

