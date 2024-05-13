<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Address;

class AddressController extends Controller
{
    public function index(Request $request)
    {
        $id_users = auth()->user()->id;
        $address = Address::where([['id_users', $id_users]])
        ->orderByDesc('created_at')
        ->limit(1)->first();

        return json_encode($address);
    }

    public function store(Request $request)
    {
        $data = request(['latitude', 'longitude', 'region', 'municipality', 'address']);

        $data['id_users'] = auth()->user()->id;

        $address = Address::create($data);

        $return['id'] = $address['id'];
        $return['status'] = true;
        $return['message'] = 'Ubicacion guardada con exito';

        return json_encode($return);
    }


}
