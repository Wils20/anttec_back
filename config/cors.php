<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Configura los permisos CORS para tu API.
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    // Permitir todos los métodos HTTP
    'allowed_methods' => ['*'],

    // Permitir cualquier origen
    'allowed_origins' => ['*'],

    // Opcional: patrones de orígenes (no se usa si allowed_origins es '*')
    'allowed_origins_patterns' => [],

    // Permitir cualquier cabecera
    'allowed_headers' => ['*'],

    // Cabeceras expuestas al frontend
    'exposed_headers' => [],

    // Tiempo máximo para cachear la preflight request
    'max_age' => 0,

    // Permitir envío de cookies o autenticación
    'supports_credentials' => false,

];
