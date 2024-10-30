local gpioPin = 50  -- Pino GPIO a ser utilizado
gpio:pinMode(gpioPin, gpio.INPUT)  -- Configura o pino como entrada

function readAndSend()
    local state = gpio:read(gpioPin)  -- Lê o estado do pino
    gcs:send_text(6, string.format("gpio: %s", tostring(state)))  -- Envia o estado para GCS

    if state == gpio.HIGH then  -- Se o estado for HIGH
        gcs:send_text(6, "Temperatura alta, niciando retorno à base e desarmando...")  -- Mensagem de ação
        
        vehicle:set_mode(vehicle.MODE_RTL)  -- Muda para modo RTH
        
        -- Aguarda até que o veículo chegue ao ponto de origem
        while not vehicle:is_home() do
            gcs:send_text(6, "Aguardando retorno à base...")
            coroutine.yield()  -- Permite que outros processos sejam executados
        end

        vehicle:arm(false)  -- Desarma o veículo
        gcs:send_text(6, "Veículo desarmado após chegar ao ponto de origem.")
    end

    return readAndSend, 1000  -- Repete a cada 1000ms (1 segundo)
end

return readAndSend, 1000  -- Inicia a função de leitura