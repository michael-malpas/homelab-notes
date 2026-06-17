echo "===== Server Audit ======"

echo
echo "Hostname:"
hostname
echo

echo
echo "Uptime:"
uptime
echo

echo
echo "Disk:"
df -h /
echo

echo
echo "Memory:"
free -h
echo

echo
echo "Docker Containers"
docker ps
echo

echo
echo "Server Audit Complete"
echo
