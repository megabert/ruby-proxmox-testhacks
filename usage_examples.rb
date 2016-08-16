#!/usr/bin/env ruby   

#
# Demo that shows creation and destruction of a proxmox qemu vm
#

require 'awesome_print'
require 'proxmox'
require 'securerandom'

proxmox_api_server = "www.my-proxmox.com"
proxmox_api_url    = "https://#{proxmox_api_server}:8006/api2/json/"
proxmox_user       = "some-proxmox-admin-user"
proxmox_password   = "your-secure-proxmox-pass"
proxmox_realm      = "pve"   # use pve or pam
proxmox_connection = Proxmox::Proxmox.new(proxmox_api_url, proxmox_api_server, proxmox_user, proxmox_password, proxmox_realm, { :verify_ssl => false })

$proxmox_node      = proxmox_api_server   # by default the api server is the only node too, be sure that fits your scenario


def mk_proxmox_vm(server,name,ram_size_mb,disk_size_mb,cores)

        id       = Proxmox::Proxmox.next_free_qemu_id(server.nodes)
        nodename = $proxmox_node
        node     = server.node_by_name(nodename)
        storage  = node.storage_by_free_space(disk_size_mb)
        if !storage then
                puts "cannot create vm: reason: cannot get a storage to provide " + disk_size_mb.to_s + " MB space"
                return
        end
        if node.free_ram_mb() < ram_size_mb then
                puts "cannot create vm: reason: node has insufficient ram: " + ram_size_mb.to_s + " MB space requested, " + node.free_ram_mb().to_s + " MB available"
                return
        end

        storname = storage.storage()

        disk_id         = SecureRandom.uuid().byteslice(0,8)
        vol_name        = "vm-"+ id.to_s + "-disk-" + disk_id
        vol_size        = disk_size_mb.to_s + "M"
        vol_format      = "raw"
        vol_vm_id       = id
        disk_name = storage.create_disk(vol_name , disk_size_mb.to_s + "M", "raw",id)
        if /error/.match(disk_name) then
                puts "cannot create vm: reason: error creating vm storage: " + disk_name.to_s
                return
        end

        data = {
                "onboot"        => "1",
                "boot"          => "ndc",
                "sockets"       => cores,
                "memory"        => ram_size_mb,
                "virtio0"       => disk_name+",cache=unsafe,size="+ (Float(disk_size_mb/1024)).floor.to_s+"G",
                "kvm"           => "1",
                "net0"          => "e1000,bridge=vmbr0",
                "net1"          => "e1000,bridge=vmbr1",
                "ostype"        => "l26",    # linux 2.6/3.x/4.x kernel
                "name"          => name, 
                "vmid"          => id
                }

        node.create_qemu(data)
end

# ----------- PROGRAM STARTS HERE ----------------------

qemu_vm = mk_proxmox_vm( proxmox_connection , "some.qemu-fqdn-name.tld", 2048, 10480, 2)
if qemu_vm then
        ap qemu_vm.id()
        sleep(10)
        qemu_vm.destroy()
end
