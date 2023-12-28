from instances import Instances
from utils import load_dict_from_file

"""Gets the private dns of the instances, we'll need them later"""

if __name__ == "__main__":
    
    data = load_dict_from_file('./data/aws_resources.json')
    instances = Instances(
        data["instance_ids"], data["security_group"], data["key"]
    )

    private_dns=instances.getPrivateDnsName(instances.instance_ids)
    print(private_dns)
    manager_private = private_dns[1]

