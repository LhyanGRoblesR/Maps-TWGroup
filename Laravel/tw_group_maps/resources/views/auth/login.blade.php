<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" style="background-color: rgba(229, 253, 235, 1)">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- CSRF Token -->
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'Laravel') }}</title>

    <!-- Fonts -->
    <link rel="dns-prefetch" href="//fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=Roboto" rel="stylesheet">

    <!-- Scripts -->
    @vite(['resources/sass/app.scss', 'resources/js/app.js'])

</head>

<body style="background-color: rgba(229, 253, 235, 1)">
    <section class="h-100 gradient-form">
        <div class="container py-5 h-100">
          <div class="row d-flex justify-content-center align-items-center h-100">
            <div class="col-xl-5">
              <div class="card rounded-3 text-black">
                <div class="row g-0">
                    <div class="col-lg-12" style="height: 200px; background-color: rgba(42, 198, 82, 1)">
                        <div class="text-center d-flex align-items-center flex-column h-100" style="">
                            <div class="rounded-circle m-auto text-center d-flex align-items-center flex-column shadow-lg" style="height: 120px; width: 120px; background-color: rgb(255, 255, 255)">
                                <div class="m-auto h1" style="color: rgba(42, 198, 82, 1); font-weight: 900">LRR</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-12">
                        <div class="card-body p-md-5 mx-md-4">
                        <form action="{{route('login')}}", method="POST">
                            @csrf
                            <p class="h3"><b> Iniciar sesión</b> / Registrarse</p>

                            <div class="input-group mb-3 mt-5">

                                <span class="input-group-text"><i class="bi bi-envelope fs-3"></i></span>
                                <div class="form-floating">
                                    <input type="text" class="form-control" id="email" name="email" placeholder="Correo electrónico">
                                    <label for="floatingInputGroup1">Correo electrónico</label>
                                </div>
                            </div>

                            <div class="input-group mb-3">
                                <span class="input-group-text"><i class="bi bi-eye-slash fs-3"></i></span>
                                <div class="form-floating">
                                    <input type="password" class="form-control" id="password" name="password" placeholder="Username">
                                    <label for="floatingInputGroup1">Contraseña</label>
                                </div>
                            </div>

                            <div class="text-center pt-1 mb-5 pb-1 mt-5">
                                <button data-mdb-button-init data-mdb-ripple-init class="btn btn-block fa-lg  mb-3 w-100" type="submit" style="background-color: rgba(42, 198, 82, 1); color: white">Iniciar sesión</button>
                            </div>


                        </form>

                        </div>
                    </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

</body>

</html>
