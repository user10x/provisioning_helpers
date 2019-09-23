#/bin/bash
echo "export PUBLIC_IP="$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "export INSTANCE_TYPE="$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
echo "export AVAILABITY_ZONE="$(curl -s  http://169.254.169.254/latest/meta-data/placement/availability-zone)
