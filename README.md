# ruby-proxmox-testhacks dummy

The following Additions had been made since version 0.0.5 to rubygem "proxmox". https://github.com/nledez/proxmox

## New Class: Proxmox.Node
### Methods: 
   * networks ( returns array of network objects from the node )
   * qemus ( returns array of existing qemu vms on the node )
   * storages ( returns array of existing storages on the node )
   * create_qemu ( creates a qemu_vm on the node )
   * qemu_by_id ( returns Proxmox.NodeQemu Object if id is found)
   * storage_by_free_space( returns Proxmox.NodeStorage Object if a storage with content images and enough free space exists)
   * storage_by_name ( returns Proxmox.NodeStorage Object if a storage with the specified name exists)
   * name ( returns node name )
   * free_ram_mb ( returns count free_ram in MB of the node )
    
## New Class: Proxmox.NodeStorage
### Methods: 
   * free ( returns free space on the storage )
   * storage ( returns the storage device name )
   * type ( returns type of the storage )
   * content ( returns type of content fo the storage )
   * create_disk ( creates a new file/image/disk on the storage )

## New Class: Proxmox.NodeQemu
### Methods: 
   * name ( Returns the Qemu-VM Name )
   * id ( Returns the Qemu-VM ID )
   * destroy ( fully destroys the vm and the linked vm-storage-files )
    
## New Class: Proxmox.NodeNetwork
    Dummy Class at the moment
    
## Extended Class: Proxmox
### New Methods:
  * STATIC: next_free_node_id( returns the next free(#max qemu id + 1) qemu id of all given nodes) 
  * nodes ( returns array of ProxmoxNode Objects for the current api server )
