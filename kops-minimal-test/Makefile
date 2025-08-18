KOPS_CLUSTER=prod-eu-north-1.k8s.local

create:
	kops create -f clusters/$(KOPS_CLUSTER)/cluster.yaml
	kops create -f clusters/$(KOPS_CLUSTER)/master-eu-north-1a.yaml
	kops create -f clusters/$(KOPS_CLUSTER)/nodes.yaml

update:
	kops update cluster $(KOPS_CLUSTER) --yes

validate:
	kops validate cluster $(KOPS_CLUSTER)
