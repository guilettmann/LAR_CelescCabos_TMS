gpio:pinMode(50, 0)  -- Configura o pino 16 como entrada

function readAndSend()
    local state = gpio:read(50)  -- Lê o estado do pino
    gcs:send_text(6, string.format("gpio: %s", tostring(state)))  -- Formata e envia o estado
    return readAndSend, 1000  -- Repete a cada 1000ms (1 segundo)
end

return readAndSend, 1000