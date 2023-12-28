from instances import Instances
from utils import load_dict_from_file

if __name__ == "__main__":
    data = load_dict_from_file('./data/gatekeeper_resources.json')
    instances = Instances(
        data["instance_ids"], data["security_group"], data["key"]
    )

    print(instances.getPublicDnsName(instances.instance_ids)[0])
