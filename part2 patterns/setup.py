from instances import Instances
from utils import save_dict_to_file

"""
This Python script uses the subprocess module to install the boto3 library. 
It then creates instances on AWS for a MySQL cluster, a proxy, and a gatekeeper.
The script waits for the instances to be in the "running" state before saving the details of the created AWS resources,
including instance IDs, security groups, and keys, into separate JSON files (cluster_resources.json, proxy_resources.json,
gatekeeper_resources.json). Additionally, the private key material for the instances is saved to a file named key.pem.
"""
import subprocess

# Install dependencies
subprocess.call(["pip", "install", "boto3"])

if __name__ == "__main__":
    instances_mysqlcluster = Instances()
    
    instances_mysqlcluster.setup(4, '12.micro')

    #1 instance for proxy
    proxy_instances = Instances(key=instances_mysqlcluster.key, security_group=instances_mysqlcluster.security_group)
    proxy_instances.create_n_instances(1, "t2.large", instances_mysqlcluster.security_group)

    # 1 instance for gatekeeper
    gatekeeper_instances = Instances(key=instances_mysqlcluster.key)
    gatekeeper_instances.create_security_group(instances_mysqlcluster.get_vpc_id, allow_ssh=True, allow_http=True)
    gatekeeper_security_groups = ["default", gatekeeper_instances.security_group["name"]]
    gatekeeper_instances.create_n_instances(1, "t2.large", gatekeeper_security_groups)

    # wait for instances to be running
    proxy_instances.wait_for_instances_running()
    gatekeeper_instances.wait_for_instances_running()

    # write aws resource info to files
    clusterjson = {
        "instance_ids": instances_mysqlcluster.instance_ids,
        "security_group": instances_mysqlcluster.security_group,
        "key": instances_mysqlcluster.key,
    }
    proxyjson = {
        "instance_ids": proxy_instances.instance_ids,
        "security_group": proxy_instances.security_group,
        "key": proxy_instances.key,
    }
    gatekeeperjson= {
        "instance_ids": gatekeeper_instances.instance_ids,
        "security_group": gatekeeper_instances.security_group,
        "key": gatekeeper_instances.key,
    }

    save_dict_to_file(clusterjson, './data/mysqlcluster.json')
    save_dict_to_file(proxyjson, './data/proxy.json')
    save_dict_to_file(gatekeeperjson, './data/gatekeeper.json')

    # write key to file
    key_file = open("./data/key.pem", "w")
    key_file.write(instances_mysqlcluster.key["KeyMaterial"])
    key_file.close()