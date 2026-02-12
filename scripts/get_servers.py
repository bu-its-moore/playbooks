import requests

VCENTER_IP = "https://timberlake.bu.binghamton.edu"
USERNAME = "s.moore@admin.binghamton.edu"
PASSWORD = "BellaEmmaNatasha77"
CLEW_API_KEY = "1iyIUlXJt1xnYLRf8vfEeby5Q98GhNP5d4UzUX1f5b43ffa6"


def get_vmware_servers():
    session = requests.Session()
    session.auth = (USERNAME, PASSWORD)
    session.verify = False
    response = session.post(f"{VCENTER_IP}/api/session")
    print(response.text, response.status_code)
    url = f"{VCENTER_IP}/api/vcenter/vm/"
    response = requests.get(url, headers=response.headers, verify=False)
    if response.status_code == 200:
        print("success!")
        servers = response.json()
    else:
        raise Exception(f" {response.status_code} : {response.text}")

    servers_detail = {}
    for server in servers:
        response = session.post(f"{VCENTER_IP}/api/session")
        url = f"{VCENTER_IP}/api/vcenter/vm/{server['vm']}/guest/networking"
        response = requests.get(url, headers=response.headers, verify=False)
        if response.status_code == 200:
            servers_detail[server["vm"]] = response.json()
            servers_detail[server["vm"]] |= server
        else:
            print(f"ERROR: {response.status_code} : {response.text}")

    return servers_detail


def get_servers():
    url = "https://clew.binghamton.edu/api/servers"
    servers_detail = {}
    headers = {"Authorization": f"Bearer {CLEW_API_KEY}"}
    response = requests.get(url, headers=headers, verify=False)
    result = response.json()
    pages = int(result["last_page"])
    for page in range(1, pages + 1):
        response = requests.get(f"{url}?page={page}", headers=headers, verify=False)
        result = response.json()
        for server in result["data"]:
            server_data = requests.get(
                f"{url}/{server['id']}", headers=headers, verify=False
            ).json()
            servers_detail[server_data["ip"]] = server_data

    return servers_detail

def main():
    servers = get_servers()
    for key, server in servers.items():
        print(f"""
- {server["name"]}
  - {key}
  - {server["os"]}
  - {server["hostname"]}.{server["domain"]}
""")
    fptr = open("servers.json", 'w')
    json.dump(fptr, servers)
    fptr.close()
if __name__ == "__main__":

