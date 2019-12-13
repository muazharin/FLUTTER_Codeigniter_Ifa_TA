<?php
defined('BASEPATH') or exit('No direct script access allowed');
class Api extends CI_Controller
{
    public function signup()
    {
        $username = $this->input->post('username');
        $email = $this->input->post('email');
        $hp = $this->input->post('hp');
        $password = md5($this->input->post('password'));
        $query1 = $this->db->query('SELECT * FROM tb_user WHERE username = "' . $username . '"');
        if ($query1->num_rows() <= 0) {
            $data = [
                'username' => $username,
                'email' => $email,
                'hp' => $hp,
                'password' => $password
            ];

            $query = $this->db->insert('tb_user', $data);
            if ($query) {
                $api = [
                    'message' => 'Account successfully added!',
                    'value' => '1'
                ];
            } else {
                $api = [
                    'message' => 'Account failed to add',
                    'value' => '1'
                ];
            }
        } else {
            $api = [
                'message' => 'Username is already exist! Please change to another one.',
                'value' => '0'
            ];
        }
        echo json_encode($api);
    }
    public function login()
    {
        $username = $this->input->post('username', true);
        $password = md5($this->input->post('password', true));
        $qwe = $this->db->query('SELECT * FROM tb_user WHERE username = "' . $username . '" AND password = "' . $password . '"');
        if ($qwe->num_rows() <= 0) {
            $data[] = [
                'value' => 0,
                'status' => 'login_gagal',
            ];
        } else {
            $a = $qwe->result();
            $data = array();
            foreach ($a as $r) {
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

    public function sendImage()
    {
        $pengirim = $this->input->post('pengirim', true);
        $penerima = $this->input->post('penerima', true);
        $kunci = $this->input->post('kunci', true);
        $pesan = $this->input->post('pesan', true);
        $ket = $this->input->post('ket', true);
        $this->load->library('upload');
        $config['upload_path'] = './assets/file_kirim';
        $config['allowed_types'] = 'jpg|jpeg|png|gif|JPG|JPEG|PNG|GIF';
        $config['file_name'] = $_FILES['image']['name'];
        $this->upload->initialize($config);
        if (!empty($_FILES['image']['name'])) {
            if ($this->upload->do_upload('image')) {
                $foto = $this->upload->data();
                $hex = unpack("H*", file_get_contents('assets/file_kirim/' . $foto['file_name']));
                $hex = current($hex);
                file_put_contents("assets/file_enc/" . $foto['file_name'], $hex);
                $data = [
                    'pengirim' => $pengirim,
                    'penerima' => $penerima,
                    'kunci' => $kunci,
                    'foto' => $foto['file_name'],
                    'pesan' => $pesan,
                    'ket' => $ket
                ];
                $this->db->insert('tb_send', $data);
                $data2 = [
                    'pengirim' => $pengirim,
                    'penerima' => $penerima,
                    'ket' => $ket
                ];
                $this->db->insert('tb_recent', $data2);
                $api = [
                    'message' => 'Data has been sent'
                ];
            } else {
                $api = [
                    'message' => 'Data failed to sent'
                ];
            }
        }
        echo json_encode($api);
    }

    public function getDataKirim()
    {
        $pengirim = $this->input->post('pengirim', true);
        $this->db->where('pengirim', $pengirim);
        $query = $this->db->get('tb_send')->result();
        $api = array();
        foreach ($query as $q) {
            $api[] = [
                'penerima' => $q->penerima,
                'kunci' => $q->kunci,
                'foto' => $q->foto,
                'pesan' => $q->pesan,
                'ket' => $q->ket
            ];
        }
        echo json_encode($api);
    }

    public function getDataInbox()
    {
        $penerima = $this->input->post('penerima', true);
        $this->db->where('penerima', $penerima);
        $query = $this->db->get('tb_send')->result();
        $api = array();
        foreach ($query as $q) {
            $api[] = [
                'pengirim' => $q->pengirim,
                'kunci' => $q->kunci,
                'foto' => $q->foto,
                'pesan' => $q->pesan,
                'ket' => $q->ket
            ];
        }
        echo json_encode($api);
    }
}
