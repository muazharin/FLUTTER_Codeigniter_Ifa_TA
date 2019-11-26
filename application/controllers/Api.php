<?php
defined('BASEPATH') OR exit('No direct script access allowed');
class Api extends CI_Controller {
    public function login(){
        $username = $this->input->post('username',true);
        $password = md5($this->input->post('password',true));
        $qwe = $this->db->query('SELECT * FROM tb_user WHERE username = "'.$username.'" AND password = "'.$password.'"');
        if($qwe->num_rows() <= 0){
            $data[]= [
                'value' => 0,
                'status' => 'login_gagal',
            ];
		}else{
            $a = $qwe->result();
            $data = array();
            foreach($a as $r){
                $data[] = [
                    'value' => 1,
                    'status' => 'login_berhasil',
                    'username' => $r->username,
                    'email' => $r->email,
                    'hp' => $r->hp
                ];    
            }
        }
        echo json_encode($data);
    }
}