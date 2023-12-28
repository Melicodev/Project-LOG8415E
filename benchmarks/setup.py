from instances import Instances
from utils import save_dict_to_file

"""this script simply initiate the instances of the manager and the workers
Writes the value of instances.key["KeyMaterial"] to the file.
Closes the file.
Constructs a dictionary named data containing information such as worker IDs, manager ID, security group, and the key.
Calls the save_dict_to_file function to save the data dictionary to a JSON file named ./data/aws_resources.json.

"""
import subprocess

# Install dependencies
subprocess.call(["pip", "install", "boto3"])

if __name__ == "__main__":
    instances = Instances()
    
    instances.setup(5, 't2.micro')

    data = {
        "instance_ids": instances.instance_ids,
        "security_group": instances.security_group,
        "key": instances.key,
    }
    print(data["instance_ids"])

    save_dict_to_file(data, './data/aws_resources.json')

    key_file = open("./data/key.pem", "w")
    key_file.write(instances.key["KeyMaterial"])
    key_file.close()
