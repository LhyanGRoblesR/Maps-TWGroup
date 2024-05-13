<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Address extends Model
{
    public $timestamps = false;
    protected $table = 'address';
    protected $primaryKey = 'id';

    protected $fillable = [
        'id_users', 'latitude', 'longitude', 'region', 'municipality', 'address', 'created_at', 'updated_at'
    ];
}
