<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App;

class HomeController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index()
    {
        $lastAddress = json_decode(App::call('App\Http\Controllers\AddressController@index'));
        // var_dump($lastAddress);
        $latitude = $lastAddress->latitude;
        $longitude = $lastAddress->longitude;
        return view('home', compact('lastAddress'));
    }

    public function store()
    {
        $response = App::call('App\Http\Controllers\AddressController@store', [request(['latitude', 'longitude', 'region', 'municipality', 'address'])]);

        return $response;

    }

}
