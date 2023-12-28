from instances import Instances
from utils import load_dict_from_file


"""Gets the public dns of the instances, we'll need them later"""

def getpublicdns():
    data = load_dict_from_file('./data/aws_resources.json')
    instances = Instances(
        data["instance_ids"], data["security_group"], data["key"]
    )

    public_dns=instances.getPublicDnsName(instances.instance_ids)

    return public_dns

if __name__ == "__main__":

    print(getpublicdns())
