<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Aquí defines cómo tu API responde a las solicitudes desde otros orígenes.
    | En este caso, permitimos todas las rutas y métodos porque tu frontend
    | está en Netlify y el backend en Render.
    |
    */

    // 🔓 Aplicar CORS a todas las rutas del backend
    'paths' => ['*'],

    // ✅ Permitir todos los métodos HTTP (GET, POST, PUT, DELETE, etc.)
    'allowed_methods' => ['*'],

    // 🌍 Permitir solicitudes desde cualquier dominio (Netlify incluido)
    'allowed_origins' => ['*'],

    // (Opcional) patrones de origen — no se usa si arriba tienes '*'
    'allowed_origins_patterns' => [],

    // ✅ Permitir cualquier cabecera
    'allowed_headers' => ['*'],

    // Cabeceras expuestas al frontend (por si las necesitas)
    'exposed_headers' => [],

    // Tiempo que el navegador puede cachear la respuesta de preflight
    'max_age' => 0,

    // ⚙️ Si usas cookies o sesiones, cámbialo a true. Si usas tokens Bearer, déjalo en false.
    'supports_credentials' => false,

];
