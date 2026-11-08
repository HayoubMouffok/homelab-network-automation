TOPO = topology/lab.clab.yml

configs:
	ansible-playbook -i ansible/inventory.yml ansible/generate.yml

deploy: configs
	sudo containerlab deploy -t $(TOPO) --reconfigure

test:
	sudo bash tests/verify.sh

destroy:
	sudo containerlab destroy -t $(TOPO) --cleanup

.PHONY: configs deploy test destroy
