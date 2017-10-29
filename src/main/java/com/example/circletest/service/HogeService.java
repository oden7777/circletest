package com.example.circletest.service;

import com.example.circletest.repository.HogeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * Created by suyamayutaro on 2017/10/29.
 */

@Service
public class HogeService {

	@Autowired
	HogeRepository hogeRepository;

	public void create()
	{
		hogeRepository.create();
	}

}
