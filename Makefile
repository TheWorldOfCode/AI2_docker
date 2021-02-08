image = ai2
container_id_file = ./container_id
mount ?= $(shell pwd)/execise
mount2 ?= $(shell pwd)/practices

build:
	sudo docker build -t $(image) .

build_dev:
	sudo docker build --build-arg DEV=true -t $(image) . 

buildrm:
	sudo docker rmi $(image)


create:
	xhost local:docker
	sudo docker run -it \
		--cidfile $(container_id_file) \
		--device /dev/dri:/dev/dri \
		-e DISPLAY \
		-v $(mount):/home/user/execise\
		-e QT_X11_NO_MITSHM=1 \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v ~/.Xauthority:/root/.Xauthority \
		--cap-add sys_ptrace \
		-p127.0.0.1:2222:22 \
		-v /run/user/1000:/run/user/1000 \
		-e XDG_RUNTIME_DIR \
		$(image) 
	
	$(shell ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222")

create_practices:
	xhost local:docker
	sudo docker run -it \
		--cidfile $(container_id_file) \
		--device /dev/dri:/dev/dri \
		-e DISPLAY \
		-v $(mount):/home/user/execise\
		-v $(mount2):/home/user/workspace/gorobots_edu/practices\
		-e QT_X11_NO_MITSHM=1 \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v ~/.Xauthority:/root/.Xauthority \
		--cap-add sys_ptrace \
		-p127.0.0.1:2222:22 \
		-v /run/user/1000:/run/user/1000 \
		-e XDG_RUNTIME_DIR \
		$(image) 
	
	$(shell ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222")

start:
	xhost local:docker
	sudo docker container start $(shell cat $(container_id_file) )
	$(shell ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222")

stop:
	sudo docker container stop $(shell cat $(container_id_file) )

rm:
	sudo docker container stop $(shell cat $(container_id_file) )
	sudo docker container rm $(shell cat $(container_id_file) )
	sudo rm $(container_id_file)

enter:
	sudo docker exec -it $(shell cat $(container_id_file)) bash
	
.PHONY: build build_dev buildrm create create_practices start stop rm enter 
