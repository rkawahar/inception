# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: kawaharadaryou <kawaharadaryou@student.    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/01/16 23:46:22 by kawaharadar       #+#    #+#              #
#    Updated: 2025/01/16 23:55:27 by kawaharadar      ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

all : up

up : 
	docker-compose -f ./srcs/docker-compose.yml up -d

down : 
	@docker-compose -f ./srcs/docker-compose.yml down

stop : 
	@docker-compose -f ./srcs/docker-compose.yml stop

start : 
	@docker-compose -f ./srcs/docker-compose.yml start

status : 
	@docker ps

logs:
	@docker-compose -f ./srcs/docker-compose.yml logs -f
